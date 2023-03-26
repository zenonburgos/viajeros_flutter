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

}
