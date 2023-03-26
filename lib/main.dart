import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:viajeros/src/pages/home/home_page.dart';
import 'package:viajeros/src/pages/login/login_page.dart';
import 'package:viajeros/src/pages/register/register_page.dart';
import 'package:viajeros/src/utils/colors.dart' as utils;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Viajeros',
      initialRoute: 'home',
      theme: ThemeData(
        fontFamily: 'NimbusSans',
        appBarTheme: const AppBarTheme(
          elevation: 0
        ),
        colorScheme: const ColorScheme.light(
          primary: utils.Colors.uberCloneColor,
          secondary: utils.Colors.uberCloneColorDark,
          error: utils.Colors.onErrorColor,
        ),
      ),
      routes: {
        'home' : (BuildContext context) => HomePage(),
        'login' : (BuildContext context) => const LoginPage(),
        'register' : (BuildContext context) => const RegisterPage(),
      },
    );
  }
}
