import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:viajeros/src/models/client.dart';
import 'package:viajeros/src/models/driver.dart';
import 'package:viajeros/src/providers/auth_provider.dart';
import 'package:viajeros/src/providers/client_provider.dart';
import 'package:viajeros/src/providers/driver_provider.dart';
import 'package:viajeros/src/providers/geofire_provider.dart';
import 'package:viajeros/src/utils/my_progress_dialog.dart';
import 'package:viajeros/src/utils/snackbar.dart' as utils;

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

  late StreamSubscription<DocumentSnapshot> _statusSubscription;
  StreamSubscription<DocumentSnapshot<Object?>>? _clientStreamSubscription;

  Client? client;

  bool isConnect = false;
  ProgressDialog? _progressDialog;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = GeofireProvider();
    _authProvider = AuthProvider();
    _driverProvider = DriverProvider();
    _clientProvider = ClientProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectándose...');
    markerDriver = (await createMarkerImageFromAsset('assets/img/taxi_icon.png'))!;
    checkGPS();
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
      _position = await Geolocator.getLastKnownPosition();
      centerPosition();

      addMarker(
          'driver',
          _position!.latitude,
          _position!.longitude,
          'Tu posición',
          '',
          markerDriver
      );
      refresh();

      const LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1
      );

      _positionStream = Geolocator.getPositionStream(
          locationSettings: locationSettings).listen((Position position) {
        _position = position;
        addMarker(
            'driver',
            _position!.latitude,
            _position!.longitude,
            'Tu posición',
            '',
            markerDriver
        );
        animateCameraToPosition(position.latitude, position.longitude);
        refresh();
      });

    } catch(error) {
      print('Error en la localización: $error');
    }
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