import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider {

  FirebaseAuth? _firebaseAuth;

  AuthProvider() {
    _firebaseAuth = FirebaseAuth.instance;
  }

  User? getUser() {
    return _firebaseAuth?.currentUser;
  }

  bool isSignedIn() {
    final currentUser = _firebaseAuth?.currentUser;

    if (currentUser == null) {
      return false;
    }

    return true;
  }

  // void checkIfUserIsLogin(BuildContext context, String typeUser) {
  //   FirebaseAuth.instance.authStateChanges().listen((User? user) {
  //     if (user != null && typeUser != null) {
  //
  //       if(typeUser == 'client') {
  //         Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
  //       }else {
  //         Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
  //       }
  //       print('El usuario está logueado.');
  //
  //     }
  //     else {
  //       print('El usuario no está logueado');
  //     }
  //   });
  // }

  Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth?.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool>? register(String email, String password) async {
    String errorMessage = '';

    try {
      await _firebaseAuth?.createUserWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      print(error);
      errorMessage = error.toString();
    }

    if (errorMessage.isNotEmpty) {
      return Future.error(Exception(errorMessage));
    }

    return true;
  }

  Future<List<void>> signOut() async {
    List<Future<void>?> futures = [_firebaseAuth?.signOut()];
    List<Future<void>> filteredFutures = futures.where((future) => future != null).map((future) => future!).toList();
    return Future.wait(filteredFutures);
  }


}
