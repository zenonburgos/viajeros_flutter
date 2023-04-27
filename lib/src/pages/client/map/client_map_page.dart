import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viajeros/src/pages/client/map/client_map_controller.dart';
import 'package:viajeros/src/widgets/button_app.dart';
import 'package:viajeros/src/utils/colors.dart' as utils;

class ClientMapPage extends StatefulWidget {
  const ClientMapPage({Key? key}) : super(key: key);

  @override
  State<ClientMapPage> createState() => _ClientMapPageState();
}

class _ClientMapPageState extends State<ClientMapPage> {

  final ClientMapController _con = ClientMapController();

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
        key: _con.key,
        drawer: _drawer(),
        body: Stack(
          children: [
            _googleMapsWidget(),
            SafeArea(
              child: Column(
                children: [
                  _buttonDrawer(),
                  _cardGooglePlaces(),
                  _buttonChangeTo(),
                  _buttonCenterPosition(),
                  Expanded(child: Container()),
                  _buttonRequest()
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: _iconMyLocation(),
            )
          ],
        )
    );
  }

  Widget _iconMyLocation() {
    return Image.asset(
        'assets/img/my_location.png',
      width: 65,
      height: 65,
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
                color: utils.Colors.accentColor
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    _con.client?.username ?? 'Nombre de usuario',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  child: Text(
                    _con.client?.email ?? 'Correo electrónico',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 10),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/img/profile.jpg'),
                  radius: 40,
                )
              ],
            ),
          ),
          ListTile(
            title: Text('Editar perfil'),
            trailing: Icon(Icons.edit),
            //leading: Icon(Icons.cancel),
            onTap: () {},
          ),
          ListTile(
            title: Text('Cerrar sesión'),
            trailing: Icon(Icons.power_settings_new),
            //leading: Icon(Icons.cancel),
            onTap: _con.signOut,
          ),
        ],
      ),
    );
  }

  Widget _buttonCenterPosition() {
    return GestureDetector(
      onTap: _con.centerPosition,
      child: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        child: Card(
          shape: const CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: const Icon(
                Icons.location_searching,
                color: Colors.black26,
                size: 20
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonChangeTo() {
    return GestureDetector(
      onTap: _con.changeFromTO,
      child: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 18),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
                Icons.sync, color: Colors.grey[600],
                size: 20
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonDrawer() {
    return Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _con.openDrawer,
        icon: const Icon(Icons.menu, color: utils.Colors.uberCloneColorDark),
      ),
    );
  }

  Widget _buttonRequest() {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        onPressed: () {
          _con.requestDriver();
        },
        text: 'SOLICITAR VEHÍCULO',
        color: utils.Colors.accentColor,
        textColor: Colors.black,
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
      onCameraMove: (position) {
        _con.initialPosition = position;
      },
      onCameraIdle: () async {
        await _con.setLocationDraggableInfo();
      },
    );
  }

  Widget _cardGooglePlaces() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoCardLocation(
                  'Desde',
                  _con.from ?? 'Lugar de recogida',
                      () async {
                    await _con.showGoogleAutoComplete(true);
                  }
              ),
              const SizedBox(height: 5),
              Container(
                  width: double.infinity,
                  child: Divider(color: Colors.grey, height: 10,)
              ),
              const SizedBox(height: 5),
              _infoCardLocation(
                  'Hasta',
                  _con.to ?? 'Lugar de destino',
                      () async {
                    await _con.showGoogleAutoComplete(false);
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCardLocation(String title, String value, VoidCallback function) {
    return GestureDetector(
      onTap: function,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 10
            ),
            textAlign: TextAlign.start,
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}

