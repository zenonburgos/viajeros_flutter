import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:viajeros/src/pages/login/login_controller.dart';
import 'package:viajeros/src/utils/colors.dart' as utils;
import 'package:viajeros/src/widgets/button_app.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final LoginController _con = LoginController();

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
      key: _con.key,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _bannerApp(),
            _textLogin(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.17),
            _textFieldEmail(),
            _textFieldPassword(),
            _buttonLogin(),
            _textDontHaveAccount()
          ],
        ),
      ),
    );
  }

  Widget _textDontHaveAccount() {
    return GestureDetector(
      //onTap: _con.goToRegisterPage,
      child: GestureDetector(
        onTap: _con.goToRegisterPage,
        child: Container(
          margin: EdgeInsets.only(bottom: 50),
          child: const Text(
            '¿No tienes una cuenta?',
            style: TextStyle(fontSize: 15, color: utils.Colors.uberCloneColor),
          ),
        ),
      ),
    );
  }

  Widget _buttonLogin() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
          onPressed: _con.login,
          color: utils.Colors.uberCloneColor,
          text: 'Iniciar Sesión',
          textColor: utils.Colors.accentColor,
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

  Widget _textLogin() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: const Text(
        'Accede',
        style: TextStyle(
            color: utils.Colors.uberCloneColorDark, fontWeight: FontWeight.bold, fontSize: 28),
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
              'assets/img/logo_inver.png',
              width: 150,
              height: 100,
            ),
            const Text(
              'Fácil y seguro',
              style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 22,
                  //color: Colors.white,
                  color: utils.Colors.accentColor,
                  fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      ),
    );
  }
}
