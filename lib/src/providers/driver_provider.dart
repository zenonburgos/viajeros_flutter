import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viajeros/src/models/driver.dart';

class DriverProvider {

  CollectionReference? _ref;

  DriverProvider() {
    _ref = FirebaseFirestore.instance.collection('Drivers');
  }

  Future<bool> create(Driver driver) async {
    try {
      await _ref?.doc(driver.id).set(driver.toJson());
      return true;
    } catch(error) {
      String errorMessage = error.toString();
      return Future.error(Exception(errorMessage));
    }
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref!.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Driver?> getById(String id) async {
    DocumentSnapshot document = await _ref!.doc(id).get();

    if(document.exists) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      Driver driver = Driver.fromJson(data);
      //print('Token del conductor: $driver.token');
      return driver;
    }

    return null;
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref!.doc(id).update(data);
  }

}
