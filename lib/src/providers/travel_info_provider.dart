import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_Info.dart';

class TravelInfoProvider {

  CollectionReference? _ref;

  TravelInfoProvider() {
    _ref = FirebaseFirestore.instance.collection('TravelInfo');
  }

  Future<bool> create(TravelInfo travelInfo) async {
    try {
      await _ref?.doc(travelInfo.id).set(travelInfo.toJson());
      return true;
    } catch(error) {
      String errorMessage = error.toString();
      return Future.error(Exception(errorMessage));
    }
  }

}