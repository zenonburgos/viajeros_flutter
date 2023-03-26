import 'package:flutter/material.dart';
import 'package:viajeros/src/models/client.dart';
import 'package:viajeros/src/providers/auth_provider.dart';
import 'package:viajeros/src/providers/client_provider.dart';

class RegisterController {

  BuildContext? context;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  AuthProvider? _authProvider;
  ClientProvider? _clientProvider;

  Future? init (BuildContext context) {
    this.context = context;
    _authProvider = AuthProvider();
    _clientProvider = ClientProvider();
  }

  void register() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    print('Email $email');
    print('Password $password');

    if (username.isEmpty && email.isEmpty && password.isEmpty && confirmPassword.isEmpty) {
      print('El usuario debe ingresar todos los campos');
      return;

    }

    if (confirmPassword != password) {
      print('Las contraseñas no coinciden');
      return;
    }

    if (password.length < 6) {
      print('El password debe tener al menos 6 caracteres');
      return;
    }

    try {

      bool isRegister = (await _authProvider?.register(email, password)) ?? false;

      if (isRegister) {

        Client client = Client(
            id: _authProvider?.getUser()?.uid ?? "",
            email: _authProvider?.getUser()?.email ?? "",
            username: username,
            password: password
        );

        await _clientProvider?.create(client);
        print('¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡El usuario se registró correctamente!!!!!!!!!!!!!!!');
      }
      else {
        print('==============El usuario no se pudo registrar===============');

      }

    } catch(error) {
      print (error);
    }
  }
}