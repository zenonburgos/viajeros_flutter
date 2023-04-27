import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viajeros/src/models/client.dart';

class ClientProvider {

  CollectionReference? _ref;

  ClientProvider() {
    _ref = FirebaseFirestore.instance.collection('Clients');
  }

  Future<bool> create(Client client) async {
    try {
      await _ref?.doc(client.id).set(client.toJson());
      return true;
    } catch(error) {
      String errorMessage = error.toString();
      return Future.error(Exception(errorMessage));
    }
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref!.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Client?> getById(String id) async {
    DocumentSnapshot<Object?>? document = await _ref?.doc(id).get();
    if (document?.exists ?? false) {
      Map<String, dynamic>? data = document?.data() as Map<String, dynamic>?;
      if (data != null) {
        String id = data['id'] ?? '';
        String email = data['email'] ?? '';
        String username = data['username'] ?? '';
        String password = data['password'] ?? '';
        Client client = Client(id: id, email: email, username: username, password: password);
        return client;
      }
    }
    return null;
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref!.doc(id).update(data);
  }

}
