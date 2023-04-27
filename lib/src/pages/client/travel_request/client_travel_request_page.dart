import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:lottie/lottie.dart';
import 'package:viajeros/src/pages/client/travel_request/client_travel_request_controller.dart';
import 'package:viajeros/src/utils/colors.dart' as utils;
import 'package:viajeros/src/widgets/button_app.dart';

class ClientTravelRequestPage extends StatefulWidget {
  const ClientTravelRequestPage({Key? key}) : super(key: key);

  @override
  State<ClientTravelRequestPage> createState() => _ClientTravelRequestPageState();
}

class _ClientTravelRequestPageState extends State<ClientTravelRequestPage> {

  final ClientTravelRequestController _con = ClientTravelRequestController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _con.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _driverInfo(),
          _lottieAnimation(),
          _textLookingFor(),
          // _textCounter(),
        ],
      ),
      bottomNavigationBar: _buttonCancel(),
    );
  }

  Widget _lottieAnimation() {
    return Lottie.asset(
      'assets/json/map-city.json',
      width: MediaQuery.of(context).size.width * 0.70,
      height: MediaQuery.of(context).size.height  * 0.35,
      fit: BoxFit.fill
    );
  }

  Widget _textLookingFor() {
    return Container(
      child: const Text(
        'Buscando conductor',
        style: TextStyle(
          fontSize: 16
        ),
      ),
    );
  }

  Widget _buttonCancel() {
    return Container(
      height: 50,
      margin: EdgeInsets.all(30),
      child: ButtonApp(
        onPressed: () {},
        text: 'Cancelar viaje',
        color: utils.Colors.accentColor,
        icon: Icons.cancel_outlined,
        textColor: Colors.black,
      ),
    );
  }

  Widget _textCounter() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30),
      child: const Text(
        '0',
        style: TextStyle(
          fontSize: 30
        ),
      ),
    );
  }

  Widget _driverInfo(){
    return ClipPath(
      clipper: WaveClipperOne(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.30,
        color: utils.Colors.uberCloneColor,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/img/profile.jpg'),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: const Text(
                'Tu conductor',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
