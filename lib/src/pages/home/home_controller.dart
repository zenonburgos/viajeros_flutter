import 'package:flutter/material.dart';
import 'package:viajeros/src/providers/auth_provider.dart';
import 'package:viajeros/src/utils/shared_pref.dart';

class HomeController {

  BuildContext? context;
  SharedPref? _sharedPref;

  AuthProvider? _authProvider;
  String? _typeUser;

  Future? init(BuildContext context) async {
    this.context = context;
    _sharedPref = SharedPref();
    _authProvider = AuthProvider();

    _typeUser = await _sharedPref?.read('typeUser');
    print('Estamos en home_controller revisando qué tipo de usuario nos viene');
    print(_typeUser);
    checkIsUserIsAuth();

  }

  void checkIsUserIsAuth() {
    bool isSigned = _authProvider?.isSignedIn() ?? false;
    if (isSigned) {
      print('_typeUser es :::::::::::::::::::::::::::');
      print(_typeUser);
      if(_typeUser == 'client') {
        print('entramos a clientes');
        Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);
      } else {
        print('entramos a conductores');
        Navigator.pushNamedAndRemoveUntil(context!, 'driver/map', (route) => false);
      }
    }
  }

  void goToLoginPage(String typeUser) {
    if (context != null) {
      saveTypeUser(typeUser);
      Navigator.pushNamed(context!, 'login');
    }
  }

  void saveTypeUser(String typeUser) async {
    await _sharedPref?.save('typeUser', typeUser);
  }


}