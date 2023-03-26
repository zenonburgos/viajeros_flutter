import 'package:flutter/material.dart';
import 'package:viajeros/src/providers/auth_provider.dart';

class LoginController {

  BuildContext? context;

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  AuthProvider? _authProvider;

  Future? init (BuildContext context) {
    this.context = context;
    _authProvider = AuthProvider();
  }

  void goToRegisterPage() {
    Navigator.pushNamed(context!, 'register');
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print('Email $email');
    print('Password $password');

    try {

      bool isLogin = (await _authProvider?.login(email, password)) ?? false;

      if (isLogin) {
        print('Está logueado.');
      }
      else {
        print('==============El usuario no se pudo loguear.===============');

      }

    } catch(error) {
      print (error);
    }
  }
}