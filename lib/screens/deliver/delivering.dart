import 'dart:async';
import '../tiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dommer/models/user.dart';
import 'package:dommer/services/auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dommer/models/delivery.dart';
import 'package:workmanager/workmanager.dart';
import 'package:dommer/services/database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

User user;
int _page = 0;
DateTime _dateFilter;
PersonalInfo personalInfo = PersonalInfo(active: false);
DatabaseService db;
List<Delivery> _deliveries = [], deliveries;
Position position;
StreamSubscription<Position> positionStreamSubscription;
bool serviceEnabled = false;
GoogleMapController _mapController;
Marker _dommerMarker = Marker(
    markerId: MarkerId('dommerMarker'),
    draggable: false,
    position:
        position != null ? LatLng(position.latitude, position.longitude) : null,
    zIndex: 2,
    flat: true,
    anchor: Offset(0.5, 0.5));
//Background track
const fetchBackground = "fetchBackground";
void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        try {
          Position _l = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          db.setDommerLocation(_l.latitude, _l.longitude);
        } catch (e) {
          print('Ubicacion desconectada');
        }
        break;
    }
    return Future.value(true);
  });
}

class Delivering extends StatefulWidget {
  @override
  _DeliveringState createState() => _DeliveringState();
}

class _DeliveringState extends State<Delivering> {
  @override
  void initState() {
    super.initState();
    Workmanager.initialize(callbackDispatcher);
    Workmanager.registerPeriodicTask("track", fetchBackground,
        frequency: Duration(minutes: 5));
  }

  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    db = DatabaseService(uid: user.uid);
    _load();
    _deliveries = Provider.of<List<Delivery>>(context);
    if (!serviceEnabled) _toggleListening(false);
    if (positionStreamSubscription == null) {
      if (personalInfo.active) _toggleListening(true);
    } else if (positionStreamSubscription.isPaused && personalInfo.active) {
      //_toggleListening(true);
    }
    return PageView(
        controller: _mainController,
        physics: NeverScrollableScrollPhysics(),
        children: _getPageWidget(_page));
  }

  List<Widget> _getPageWidget(int page) {
    if (page == 0) {
      if (_dateFilter != null) {
        deliveries = _deliveries
            .where((d) =>
                d.date.year == _dateFilter.year &&
                d.date.month == _dateFilter.month &&
                d.date.day == _dateFilter.day)
            .toList();
      } else {
        deliveries = _deliveries
            .skipWhile((d) => (d.date.isBefore(DateTime.now()
                    .subtract(Duration(hours: DateTime.now().hour + 1))) &&
                d.status == 'Entregado'))
            .toList();
      }
      if (deliveries != null) {
        deliveries.retainWhere((d) => d.dommerId == user.uid);
        deliveries.sort((a, b) => a.step.compareTo(b.step));
      }
      return [
        Scaffold(
            appBar:
                AppBar(title: Text('Entregador'), centerTitle: true, actions: [
              IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _applyDateFilter(context))
            ]),
            body: personalInfo.active
                ? deliveries != null
                    ? deliveries.isNotEmpty
                        ? ListView.builder(
                            itemCount: deliveries.length,
                            itemBuilder: (context, i) {
                              return DeliveryTile(
                                  delivery: deliveries[i], support: false);
                            })
                        : Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                Icon(Icons.emoji_people, size: 150),
                                Text('Todo está tranquilo por aquí...',
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1.5)
                              ]))
                    : Container()
                : Center(
                    child: Text(
                        'Deberás activarte para continuar realizando entregas',
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.5)),
            drawerEdgeDragWidth: 50,
            drawer: _drawer(),
            bottomSheet: Container(
                width: MediaQuery.of(context).size.width * .85,
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.purple,
                          blurRadius: .5,
                          spreadRadius: .5),
                      BoxShadow(spreadRadius: -5, blurRadius: 8)
                    ],
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(50))),
                child: SwitchListTile(
                    title: Text(
                      personalInfo.active ? 'Estás activo' : 'Estás inactivo',
                      style: TextStyle(
                          color:
                              personalInfo.active ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    subtitle: Text(personalInfo.active
                        ? 'Estamos buscando un pedido perfecto para ti'
                        : 'Deberás activarte para empezar a realizar pedidos'),
                    value: personalInfo.active,
                    onChanged: (a) => showDialog(
                        context: context,
                        child: Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          'Vamos a cambiar tu estado, confirma para proceder'),
                                      RaisedButton(
                                          child: Text(personalInfo.active
                                              ? 'Desactivar'
                                              : 'Activar'),
                                          onPressed: () {
                                            _toggleListening(a);
                                            Navigator.pop(context);
                                            //if (a) {Workmanager.initialize(callbackDispatcher);} else {Workmanager.cancelAll();}
                                          })
                                    ])))))))
      ];
    } else if (_page == 1) {
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(12, 12)), 'assets/images/bike.png')
          .then((onValue) {
        setState(() {
          _dommerMarker = _dommerMarker.copyWith(iconParam: onValue);
        });
      });
      Set<Marker> _createMarkers() {
        var _tmp = Set<Marker>();
        if (_dommerMarker.position != null) _tmp.add(_dommerMarker);
        return _tmp;
      }

      return [
        Scaffold(
            appBar: AppBar(title: Text('Mapa'), centerTitle: true),
            body: Container(
              child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(10.9743669, -74.8006832), zoom: 13),
                  markers: _createMarkers(),
                  compassEnabled: true,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  onMapCreated: _onMapCreated),
            ),
            drawerEdgeDragWidth: 50,
            drawer: _drawer())
      ];
    } else if (_page == 2) {
      return [
        Scaffold(
            appBar: AppBar(title: Text('Perfil')),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  CircleAvatar(
                      child: Icon(Icons.bike_scooter, size: 100), radius: 100),
                  Text(
                    '\n${personalInfo.name} ${personalInfo.lastName}',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 30),
                  ),
                  Text('\n\nTeléfono: ${personalInfo.phone}'),
                  Text('\n${personalInfo.role} autorizado\n'),
                  Text(
                      'Domo declara que ${personalInfo.name} ${personalInfo.lastName} hace parte de su equipo de trabajo y se encuenta actualmente activo y autorizado para laborar en la plataforma.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10))
                ]),
            drawerEdgeDragWidth: 50,
            drawer: _drawer())
      ];
    } else {
      return [
        Scaffold(
            appBar: AppBar(
              title: Text('Balance'),
              centerTitle: true,
            ),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50, width: MediaQuery.of(context).size.width),
                  CircleAvatar(
                      child: Icon(Icons.monetization_on, size: 100),
                      radius: 100),
                  Text(
                    '\n¡Hola Dommer!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 30),
                  ),
                  Text('\n\nTu saldo disponible es'),
                  Text('${personalInfo.balance}',
                      style: TextStyle(
                          color: personalInfo.balance < 3000
                              ? Colors.red[700]
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25))
                ]),
            drawerEdgeDragWidth: 50,
            drawer: _drawer())
      ];
    }
  }

  void _applyDateFilter(BuildContext context) async {
    _dateFilter = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2021, 12, 31),
        cancelText: 'Borrar filtro');
    setState(() {});
  }

  void _load() async {
    personalInfo = await db.personalInfo.first;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
  }

  void _onMapCreated(GoogleMapController c) {
    _mapController = c;
    if (position != null) {
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15)));
    } else {
      print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Position null');
    }
  }

  void _toggleListening(bool active) {
    db.setActive(active);
    if (positionStreamSubscription == null) {
      final positionStream =
          Geolocator.getPositionStream(intervalDuration: Duration(seconds: 10));
      positionStreamSubscription = positionStream.handleError((error) {
        positionStreamSubscription.cancel();
        positionStreamSubscription = null;
      }).listen((p) {
        setState(() {
          position = p;
          db.setDommerLocation(p.latitude, p.longitude);
          if (_page == 1) _updateMarker(p);
        });
      });
      positionStreamSubscription.pause();
    }
    setState(() {
      if (positionStreamSubscription.isPaused) {
        positionStreamSubscription.resume();
      } else {
        positionStreamSubscription.pause();
      }
    });
  }

  void _updateMarker(Position p) {
    _dommerMarker = _dommerMarker.copyWith(
        positionParam: LatLng(p.latitude, p.longitude),
        rotationParam: p.heading);
    //_mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(p.latitude, p.longitude), zoom: 15)));
  }

  refresh() {
    setState(() {});
  }

  Widget _drawer() {
    return Drawer(
        child: ListView(children: [
      UserAccountsDrawerHeader(
        accountName: Text(personalInfo != null
            ? '${personalInfo.name} ${personalInfo.lastName}'
            : ''),
        accountEmail: Text(personalInfo != null ? '${personalInfo.role}' : ''),
        arrowColor: Colors.teal,
        currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.bike_scooter,
                color: Theme.of(context).primaryColor, size: 50)),
      ),
      ListTile(
          title: Text('Inicio'),
          selected: _page == 0,
          leading: Icon(Icons.home),
          onTap: () {
            setState(() {
              _page = 0;
            });
            Navigator.pop(context);
          }),
      ListTile(
          title: Text('Mapa'),
          selected: _page == 1,
          leading: Icon(Icons.map),
          onTap: () {
            setState(() {
              _page = 1;
            });
            Navigator.pop(context);
          }),
      ListTile(
          title: Text('Perfil'),
          selected: _page == 2,
          leading: Icon(Icons.person),
          onTap: () {
            setState(() {
              _page = 2;
            });
            Navigator.pop(context);
          }),
      ListTile(
          title: Text('Mis ganancias'),
          selected: _page == 3,
          leading: Icon(Icons.monetization_on),
          onTap: () {
            setState(() {
              _page = 3;
            });
            Navigator.pop(context);
          }),
      ListTile(
          title: Text('Cerrar sesión'),
          leading: Icon(Icons.logout),
          onTap: () {
            db.setActive(false);
            AuthService().signOut();
          })
    ]));
  }
}

PageController _mainController = PageController();
void goToPage(int page) {
  _mainController.animateToPage(page,
      duration: Duration(milliseconds: 800), curve: Curves.bounceInOut);
}
