import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:viajeros/src/pages/register/register_controller.dart';
import 'package:viajeros/src/utils/colors.dart' as utils;
import 'package:viajeros/src/widgets/button_app.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final RegisterController _con = RegisterController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _bannerApp(),
            _textLogin(),
            _textFieldUsername(),
            _textFieldEmail(),
            _textFieldPassword(),
            _textFieldConfirmPassword(),
            _buttonRegister()
          ],
        ),
      ),
    );
  }

  Widget _buttonRegister() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
          onPressed: _con.register,
          color: utils.Colors.uberCloneColor,
          text: 'Registrar',
          textColor: Colors.white,
      ),
    );
  }

  Widget _textFieldEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.emailController,
        decoration: const InputDecoration(
            hintText: 'tucorreo@mail.com',
            labelText: 'Correo Electrónico',
            suffixIcon: Icon(
              Icons.email_outlined,
              color: utils.Colors.uberCloneColor,
            )),
      ),
    );
  }

  Widget _textFieldUsername() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.usernameController,
        decoration: const InputDecoration(
            hintText: 'Tu Nombre',
            labelText: 'Nombre de usuario',
            suffixIcon: Icon(
              Icons.person_outline,
              color: utils.Colors.uberCloneColor,
            )),
      ),
    );
  }

  Widget _textFieldPassword() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: TextField(
        controller: _con.passwordController,
        obscureText: true,
        //controller: _con.passwordController,
        decoration: const InputDecoration(
            labelText: 'Contraseña',
            suffixIcon: Icon(
              Icons.lock_open_outlined,
              color: utils.Colors.uberCloneColor,
            )),
      ),
    );
  }

  Widget _textFieldConfirmPassword() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: TextField(
        controller: _con.confirmPasswordController,
        obscureText: true,
        //controller: _con.passwordController,
        decoration: const InputDecoration(
            labelText: 'Confirmar Contraseña',
            suffixIcon: Icon(
              Icons.lock_open_outlined,
              color: utils.Colors.uberCloneColor,
            )),
      ),
    );
  }

  Widget _textLogin() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: const Text(
        'REGISTRO',
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25
        ),
      ),
    );
  }

  Widget _bannerApp() {
    return ClipPath(
      clipper: WaveClipperTwo(),
      child: Container(
        color: utils.Colors.uberCloneColor,
        height: MediaQuery.of(context).size.height * 0.22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/img/logo_app.png',
              width: 150,
              height: 100,
            ),
            const Text(
              'Fácil y seguro',
              style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      ),
    );
  }
}
