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
    DocumentSnapshot<Object?>? document = await _ref?.doc(id).get();
    if (document?.exists ?? false) {
      Map<String, dynamic>? data = document?.data() as Map<String, dynamic>?;
      if (data != null) {
        String id = data['id'] ?? '';
        String email = data['email'] ?? '';
        String username = data['username'] ?? '';
        String password = data['password'] ?? '';
        String plate = data['plate'] ?? '';
        Driver driver = Driver(id: id, email: email, username: username, password: password, plate: plate);
        return driver;
      }
    }
    return null;
  }

}
