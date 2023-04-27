import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:viajeros/src/providers/client_provider.dart';
import 'package:viajeros/src/providers/driver_provider.dart';
import 'package:http/http.dart' as http;
import 'package:viajeros/src/utils/shared_pref.dart';


class PushNotificationsProvider {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final StreamController _streamController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get message => _streamController.stream.cast<Map<String, dynamic>>();

  void initPushNotifications() {

    // ON LAUNCH
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Map<String, dynamic> data = message.data;
        SharedPref sharedPref = SharedPref();
        sharedPref.save('isNotification', 'true');
        _streamController.sink.add(data);

      }
    });

    // ON MESSAGE
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      Map<String, dynamic> data = message.data;

      print('Cuando estamos en primer plano');
      print('OnMessage: $data');
      _streamController.sink.add(data);

    });

    // ON RESUME
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Map<String, dynamic> data = message.data;
      print('OnResume $data');
      _streamController.sink.add(data);
    });
  }

  void saveToken(String idUser, String typeUser) async {
    String? token = await _firebaseMessaging.getToken();
    Map<String, dynamic> data = {
      'token': token
    };

    if(typeUser == 'client') {
      ClientProvider clientProvider = ClientProvider();
      clientProvider.update(data, idUser);
    }
    else{
      DriverProvider driverProvider = DriverProvider();
      driverProvider.update(data, idUser);
    }

    print('Token: $token');
  }

  Future<void> sendMessage(String to, Map<String, dynamic> data, String title, String body) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAA0jsr8-g:APA91bF2K-jnYU1neZHMtU5Amp1Yxz9t_-WRHnovWXQA1C0E1bjI9DdFSYbx8sg9BiEFt3RD3s1X1CpraXTGiUkHyE6BpDwolAIK624flVZnokICE4p5Dmh9E2bRH5VbydwEuZ4O8lzo'
      },
      body: jsonEncode(<String, dynamic>{
        'notification': <String, dynamic>{
          'body': body,
          'title': title,
        },
        'priority': 'high',
        'time_to_live': 4500,
        'data': data,
        'to': to
      }),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
      print(data);
      print(to);
    } else {
      print('Error sending message: ${response.statusCode} - ${response.body}');
    }
  }

  void dispose() {
    _streamController.close();
  }
}