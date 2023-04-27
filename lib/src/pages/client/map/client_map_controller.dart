import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:viajeros/src/environment/api.dart';
import 'package:viajeros/src/models/client.dart';
import 'package:viajeros/src/models/driver.dart';
import 'package:viajeros/src/providers/auth_provider.dart';
import 'package:viajeros/src/providers/client_provider.dart';
import 'package:viajeros/src/providers/driver_provider.dart';
import 'package:viajeros/src/providers/geofire_provider.dart';
import 'package:viajeros/src/providers/push_notifications_provider.dart';
import 'package:viajeros/src/utils/my_progress_dialog.dart';
import 'package:viajeros/src/utils/snackbar.dart' as utils;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';

class ClientMapController {
  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = const CameraPosition(
      target: LatLng(13.9738689, -89.7527018),
      zoom: 14.0
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Position? _position;
  late StreamSubscription<Position> _positionStream;

  late BitmapDescriptor markerDriver;

  late GeofireProvider _geofireProvider;
  late AuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late ClientProvider _clientProvider;
  late PushNotificationsProvider _pushNotificationsProvider;

  late StreamSubscription<DocumentSnapshot> _statusSubscription;
  StreamSubscription<DocumentSnapshot<Object?>>? _clientStreamSubscription;

  Client? client;

  String? from;
  LatLng? fromLatLng;

  String? to;
  LatLng? toLatLng;

  bool isFromSelected = true;

  final places.GoogleMapsPlaces _places = places.GoogleMapsPlaces(apiKey: Environment.API_KEY_MAPS);

  bool isConnect = false;
  ProgressDialog? _progressDialog;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = GeofireProvider();
    _authProvider = AuthProvider();
    _driverProvider = DriverProvider();
    _clientProvider = ClientProvider();
    _pushNotificationsProvider = PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectándose...');
    markerDriver = (await createMarkerImageFromAsset('assets/img/icon_taxi.png'))!;
    checkGPS();
    saveToken();
    getClientInfo();
  }

  void getClientInfo() {
    User? user = _authProvider.getUser();
    if (user != null) {
      Stream<DocumentSnapshot<Object?>> clientStream =
      _clientProvider.getByIdStream(user.uid);
      _clientStreamSubscription = clientStream.listen((DocumentSnapshot document) {
        if (document.exists) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          client = Client.fromJson(data ?? {});
          refresh();
        }
      });
    } else {
      // handle the case when the user is not authenticated
    }
  }

  void openDrawer() {
    key.currentState?.openDrawer();
  }

  void dispose() {
    _positionStream?.cancel();
    _statusSubscription?.cancel();
    _clientStreamSubscription?.cancel();
  }

  void signOut() async {
    await _authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition(); //Obtener posición una única vez
      centerPosition();
      getNearbyDrivers();

    } catch(error) {
      print('Error en la localización: $error');
    }
  }

  void requestDriver() {
    if (fromLatLng != null && toLatLng != null){
      Navigator.pushNamed(context, 'client/travel/info', arguments: {
        'from': from,
        'to': to,
        'fromLatLng': fromLatLng,
        'toLatLng': toLatLng
      });
    }
    else{
      utils.Snackbar.showSnackbar(context, key, 'Seleccionar el lugar de recogida y destino.');
    }
  }

  void changeFromTO() {
    isFromSelected = !isFromSelected;

    if (isFromSelected) {
      utils.Snackbar.showSnackbar(context, key, 'Estás seleccionando el lugar de recogida');
    }
    else {
      utils.Snackbar.showSnackbar(context, key, 'Estás seleccionando el destino');
    }
  }

  Future<Null> showGoogleAutoComplete(bool isFrom) async {
    places.Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: Environment.API_KEY_MAPS,
      language: 'es',
      strictbounds: true,
      radius: 5000,
      location: places.Location(lat: 13.9770825, lng: -89.7546227),
    );

    if(p != null) {
      places.PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId!, language: 'es');
      double lat = detail.result.geometry!.location.lat;
      double lng = detail.result.geometry!.location.lng;
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String? direction = placemark.thoroughfare;
        String? city = placemark.locality;
        String? department = placemark.administrativeArea;

        if(isFrom) {
          from = '$direction, $city, $department';
          fromLatLng = LatLng(lat, lng);
        }
        else{
          to = '$direction, $city, $department';
          toLatLng = LatLng(lat, lng);
        }
        refresh();
      }
    }
  }

  Future<Null> setLocationDraggableInfo() async {
    if (initialPosition != null) {
      double lat = initialPosition.target.latitude;
      double lng = initialPosition.target.longitude;

      List<Placemark> address = await placemarkFromCoordinates(lat, lng);

      if (address.isNotEmpty) {
        String? direction = address[0].thoroughfare;
        String? street = address[0].subThoroughfare;
        String? city = address[0].locality;
        String? department = address[0].administrativeArea;
        String? country = address[0].country;

        if (isFromSelected) {
          from = '$direction, $street, $city, $department';
          fromLatLng = LatLng(lat, lng);
        }
        else {
          to = '$direction #$street, $city, $department';
          toLatLng = LatLng(lat, lng);
        }

        refresh();
      }
    }
  }

  void saveToken() {
    _pushNotificationsProvider.saveToken(_authProvider.getUser()!.uid, 'client');
  }

  void getNearbyDrivers() {
    Stream<List<DocumentSnapshot>> stream =
    _geofireProvider.getNearbyDrivers(_position!.latitude, _position!.longitude, 50);

    stream.listen((List<DocumentSnapshot> documentList) {

      for (DocumentSnapshot d in documentList) {
        print('DOCUMENT: $d');
      }

      for (MarkerId m in markers.keys) {
        bool remove = true;

        for (DocumentSnapshot d in documentList) {
          if (m.value == d.id) {
            remove = false;
          }
        }

        if (remove) {
          markers.remove(m);
          refresh();
        }

      }

      for (var d in documentList) {
        var point = (d.data() as Map<String, dynamic>?)?['position']?['geopoint'] as GeoPoint?;
        if (point != null) {
          addMarker(
            d.id,
            point.latitude,
            point.longitude,
            'Conductor disponible',
            d.id,
            markerDriver,
          );
        }
      }



      refresh();

    });
  }


  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position?.latitude, _position?.longitude);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activa la ubicación para obtener la posición.')));
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS ACTIVADO');
      bool isDeviceLocationEnabled = await location.Location().serviceEnabled();
      if (isDeviceLocationEnabled) {
        print('UBICACIÓN ACTIVADA EN EL DISPOSITIVO');
        updateLocation();
      } else {
        print('UBICACIÓN DESACTIVADA EN EL DISPOSITIVO');
        bool permissionGranted = await location.Location().requestService();
        if (permissionGranted) {
          print('UBICACIÓN ACTIVADA POR EL USUARIO');
          updateLocation();
        } else {
          print('UBICACIÓN NO AUTORIZADA');
        }
      }
    }
    else {
      print('GPS DESACTIVADO');
      utils.Snackbar.showSnackbar(context, key, 'Activa el GPS para obtener la posición.');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future? animateCameraToPosition(double? latitude, double? longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              bearing: 0,
              target: LatLng(latitude!, longitude!),
              zoom: 17
          )
      ));
    }
  }

  Future<BitmapDescriptor>? createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
      ){

    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
        markerId: id,
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        rotation: _position!.heading
    );

    markers[id] = marker;
  }
}