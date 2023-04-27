import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:viajeros/src/environment/api.dart';
import 'package:viajeros/src/models/directions.dart';

class GoogleProvider {

  Future<dynamic>? getGoogleMapsDirections (double fromLat, double fromLng, double toLat, double toLng) async {

    Uri uri = Uri.https(
        'maps.googleapis.com',
        'maps/api/directions/json', {
          'key': Environment.API_KEY_MAPS,
          'origin': '$fromLat,$fromLng',
          'destination': '$toLat,$toLng',
          'traffic_model': 'best_guess',
          'departure_time': DateTime.now().microsecondsSinceEpoch.toString(),
          'mode': 'driving',
          'transit_routing_preference': 'less_driving'
        }
    );
    print('URL: $uri');
    final response = await http.get(uri);
    final decodedData = json.decode(response.body);
    final leg = Direction.fromJsonMap(decodedData['routes'][0]['legs'][0]);
    return leg;

  }
}