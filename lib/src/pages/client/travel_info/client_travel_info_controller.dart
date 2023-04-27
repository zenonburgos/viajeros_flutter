import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viajeros/src/environment/api.dart';
import 'package:viajeros/src/models/directions.dart';
import 'package:viajeros/src/models/prices.dart';
import 'package:viajeros/src/providers/google_provider.dart';
import 'package:viajeros/src/providers/prices_provider.dart';
import 'package:viajeros/src/utils/colors.dart' as utils;

class ClientTravelInfoController {

  BuildContext? context;

  GoogleProvider? _googleProvider;
  PricesProvider? _pricesProvider;

  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = const CameraPosition(
      target: LatLng(13.9738689, -89.7527018),
      zoom: 14.0
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  String? from;
  String? to;
  LatLng? fromLatLng;
  LatLng? toLatLng;

  Set<Polyline> polylines = {};
  List<LatLng> points = [];

  BitmapDescriptor? fromMarker;
  BitmapDescriptor? toMarker;

  Direction? _directions;
  String? min;
  String? km;

  double? minTotal;
  double? maxTotal;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    Map<String, dynamic> arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    from = arguments['from'];
    to = arguments['to'];
    fromLatLng = arguments['fromLatLng'];
    toLatLng = arguments['toLatLng'];

    _googleProvider = GoogleProvider();
    _pricesProvider = PricesProvider();

    fromMarker = (await createMarkerImageFromAsset('assets/img/map_pin_red.png'))!;
    toMarker = (await createMarkerImageFromAsset('assets/img/map_pin_blue.png'))!;

    animateCameraToPosition(fromLatLng!.latitude, fromLatLng!.longitude);
    getGoogleMapsDirections(fromLatLng!, toLatLng!);
  }

  void getGoogleMapsDirections(LatLng from, LatLng to) async {
    _directions = await _googleProvider?.getGoogleMapsDirections(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude
    );
    min = _directions?.duration?.text;
    km = _directions?.distance?.text;

    calculatePrice();
    refresh();
  }

  void goToRequest() {
    Navigator.pushNamed(context!, 'client/travel/request', arguments: {
      'from': from,
      'to': to,
      'fromLatLng': fromLatLng,
      'toLatLng': toLatLng
    });
  }

  void calculatePrice() async {
    Prices prices = await _pricesProvider!.getAll();
    double kmValue = double.parse(km!.split(" ")[0]) * prices.km;
    double minValue = double.parse(min!.split(" ")[0]) * prices.min;
    double total = kmValue + minValue;

    minTotal = total - 0.5;
    maxTotal = total + 0.5;

    refresh();
  }

  Future<void> setPolylines() async{
    PointLatLng pointFromLatLng = PointLatLng(fromLatLng!.latitude, fromLatLng!.longitude);
    PointLatLng pointToLatLng = PointLatLng(toLatLng!.latitude, toLatLng!.longitude);

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        Environment.API_KEY_MAPS,
        pointFromLatLng,
        pointToLatLng
    );

    for (PointLatLng point in result.points) {
      points.add(LatLng(point.latitude, point.longitude));
    }

    Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: utils.Colors.accentColor,
        points: points,
        width: 6
    );

    polylines.add(polyline);

    addMarker('from', fromLatLng!.latitude, fromLatLng!.longitude, 'Recoger aquí', '', fromMarker!);
    addMarker('to', toLatLng!.latitude, toLatLng!.longitude, 'Destino', '', toMarker!);

    refresh();
  }

  Future? animateCameraToPosition(double? latitude, double? longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              bearing: 0,
              target: LatLng(latitude!, longitude!),
              zoom: 14
          )
      ));
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    await setPolylines();
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
    );

    markers[id] = marker;
  }
}