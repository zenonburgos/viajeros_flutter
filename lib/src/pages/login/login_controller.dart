import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:viajeros/src/models/client.dart';
import 'package:viajeros/src/models/driver.dart';
import 'package:viajeros/src/providers/auth_provider.dart';
import 'package:viajeros/src/providers/client_provider.dart';
import 'package:viajeros/src/providers/driver_provider.dart';
import 'package:viajeros/src/utils/my_progress_dialog.dart';
import 'package:viajeros/src/utils/shared_pref.dart';
import 'package:viajeros/src/utils/snackbar.dart' as utils;

class LoginController {
  late BuildContext context;
  final key = GlobalKey<ScaffoldState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AuthProvider _authProvider;
  late ProgressDialog _progressDialog;
  late DriverProvider _driverProvider;
  late ClientProvider _clientProvider;

  late SharedPref _sharedPref;
  late String _typeUser;

  Future<void> init(BuildContext context) async {
    this.context = context;
    _authProvider = AuthProvider();
    _driverProvider = DriverProvider();
    _clientProvider = ClientProvider();
    _progressDialog =
        MyProgressDialog.createProgressDialog(context, 'Ingresando, espere un momento...');
    _sharedPref = SharedPref();
    _typeUser = await _sharedPref.read('typeUser') as String;

    print('============= TIPO DE USUARIO ===========');
    print(_typeUser);
  }

  void goToRegisterPage() {
    if (_typeUser == 'client') {
      Navigator.pushNamed(context, 'client/register');
    } else {
      Navigator.pushNamed(context, 'driver/register');
    }
  }

  Future<void> login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    print('Email: $email');
    print('Password: $password');

    _progressDialog.show();

    try {
      final bool isLogin = await _authProvider.login(email, password);
      _progressDialog.hide();
      print('Esto es isLogin...............: $isLogin');
      if (isLogin) {
        print('El usuario está logueado');

        if (_typeUser == 'client') {
          final Client? client = await _clientProvider.getById(_authProvider.getUser()!.uid);
          print('CLIENTE: $client');

          if (client != null) {
            Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
          } else {
            utils.Snackbar.showSnackbar(context, key, 'El usuario no es válido.');
            await _authProvider.signOut();
          }
        } else if (_typeUser == 'driver') {
          final Driver? driver = await _driverProvider.getById(_authProvider.getUser()!.uid);
          print('DRIVER: $driver');

          if (driver != null) {
            Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
          } else {
            utils.Snackbar.showSnackbar(context, key, 'El usuario no es válido.');
            await _authProvider.signOut();
          }
        }
      } else {
        print('El usuario no se pudo autenticar.');
        utils.Snackbar.showSnackbar(context, key, 'El usuario no se pudo autenticar.');
      }
    } catch (error) {
      utils.Snackbar.showSnackbar(context, key, 'Error: $error');
      _progressDialog.hide();
      print('Error: $error');
    }
  }
}