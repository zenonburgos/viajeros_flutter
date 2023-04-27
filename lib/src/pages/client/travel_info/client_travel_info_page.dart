import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viajeros/src/pages/client/travel_info/client_travel_info_controller.dart';
import 'package:viajeros/src/widgets/button_app.dart';
import 'package:viajeros/src/utils/colors.dart' as utils;

class ClientTravelInfoPage extends StatefulWidget {
  const ClientTravelInfoPage({Key? key}) : super(key: key);

  @override
  State<ClientTravelInfoPage> createState() => _ClientTravelInfoPageState();
}

class _ClientTravelInfoPageState extends State<ClientTravelInfoPage> {
  final ClientTravelInfoController _con = ClientTravelInfoController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _googleMapsWidget(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _cardTavelInfo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: _buttonBack(),
          ),
          Align(
            alignment: Alignment.topRight,
            child: _cardKmInfo(_con.km ?? ""),
          ),
          Align(
            alignment: Alignment.topRight,
            child: _cardMinInfo(_con.min ?? ""),
          )
        ],
      ),
    );
  }

  Widget _cardTavelInfo(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.38,
      decoration: BoxDecoration(
        color: Colors.grey[200],
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Desde',
              style: TextStyle(
                fontSize: 15
              ),
            ),
            subtitle: Text(
              _con.from ?? '',
              style: const TextStyle(
                fontSize: 13
              ),
            ),
            leading: Icon(Icons.location_on),
          ),
          ListTile(
            title: const Text(
              'Hasta',
              style: TextStyle(
                  fontSize: 15
              ),
            ),
            subtitle: Text(
              _con.to ?? '',
              style: const TextStyle(
                  fontSize: 13
              ),
            ),
            leading: Icon(Icons.my_location),
          ),
          ListTile(
            title: const Text(
              'Precio',
              style: TextStyle(
                  fontSize: 15
              ),
            ),
            subtitle: Text(
              '\$ ${_con.minTotal?.toStringAsFixed(2) ?? '0.00'} - \$ ${_con.maxTotal?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                  fontSize: 13
              ),
              maxLines: 1,
            ),
            leading: Icon(Icons.attach_money),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: ButtonApp(
                onPressed: _con.goToRequest,
                text: 'CONFIRMAR',
                textColor: Colors.black,
                color: utils.Colors.accentColor
            ),
          )
        ],
      ),
    );
  }

  Widget _cardKmInfo(String km) {
    return SafeArea(
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          margin: const EdgeInsets.only(right: 10, top: 10),
          decoration: const BoxDecoration(
            color: utils.Colors.accentColor,
            borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text(km ?? '0 Km', maxLines: 1,),
        )
    );
  }

  Widget _cardMinInfo(String min) {
    return SafeArea(
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          margin: const EdgeInsets.only(right: 10, top: 35),
          decoration: const BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text(min ?? '0 Min', maxLines: 1,),
        )
    );
  }

  Widget _buttonBack(){
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        child: const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_back, color: Colors.black),
        )
      ),
    );
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      polylines: _con.polylines,
    );
  }

  void refresh() {
    setState(() {

    });
  }
}
