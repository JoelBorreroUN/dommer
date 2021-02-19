import 'add_user.dart';
import 'add_dommer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dommer/models/user.dart';
import 'package:dommer/screens/tiles.dart';
import 'package:dommer/services/auth.dart';
import 'package:dommer/models/delivery.dart';
import 'package:dommer/services/database.dart';
import 'package:dommer/screens/support/add_delivery.dart';

class Support extends StatefulWidget {
  @override
  _SupportState createState() => _SupportState();
}

DateTime _dateFilter;
PersonalInfo personalInfo;
int _page = 0;
List<Delivery> _deliveries;
List<PersonalInfo> users = [], dommers = [];
void fillUsers() async {
  users = await DatabaseService().usersInfo;
}

void fillDommers() async {
  dommers = await DatabaseService().dommersInfo;
}

class _SupportState extends State<Support> {
  @override
  Widget build(BuildContext context) {
    _load();
    _deliveries = Provider.of<List<Delivery>>(context);
    return PageView(
        controller: _mainController,
        physics: NeverScrollableScrollPhysics(),
        children: _getPageWidget(_page));
  }

  List<Widget> _getPageWidget(int page) {
    if (page == 0) {
      List<Delivery> deliveries;
      if (_dateFilter != null) {
        deliveries = _deliveries
            .where((d) =>
                d.date.year == _dateFilter.year &&
                d.date.month == _dateFilter.month &&
                d.date.day == _dateFilter.day)
            .toList();
      } else {
        deliveries = _deliveries;
      }
      if (deliveries != null)
        deliveries.sort((a, b) => a.step.compareTo(b.step));
      return [
        Scaffold(
            appBar: AppBar(title: Text('Soporte'), centerTitle: true, actions: [
              IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _applyDateFilter(context))
            ]),
            body: deliveries != null
                ? deliveries.isNotEmpty
                    ? ListView.builder(
                        itemCount: deliveries.length,
                        itemBuilder: (context, i) {
                          return DeliveryTile(
                              delivery: deliveries[i], support: true);
                        })
                    : Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_people, size: 150),
                          Text('Todo está tranquilo por aquí...')
                        ],
                      ))
                : Container(),
            drawerEdgeDragWidth: 50,
            drawer: _drawer(),
            floatingActionButton: FloatingActionButton.extended(
                icon: Icon(Icons.add_road),
                label: Text('Añadir ruta'),
                onPressed: () {
                  goToPage(1);
                })),
        AddDelivery()
      ];
    } else if (_page == 1) {
      fillUsers();
      return [
        Scaffold(
            appBar: AppBar(title: Text('Clientes'), centerTitle: true),
            body: users != null
                ? users.isNotEmpty
                    ? ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, i) {
                          return UserTile(user: users[i]);
                        })
                    : Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.block, size: 150),
                          Text('Necesitamos clientes')
                        ],
                      ))
                : Container(),
            drawerEdgeDragWidth: 50,
            drawer: _drawer(),
            floatingActionButton: FloatingActionButton.extended(
                icon: Icon(Icons.person_add),
                label: Text('Añadir cliente'),
                onPressed: () {
                  goToPage(1);
                })),
        AddUser()
      ];
    } else {
      return [
        Scaffold(
            appBar: AppBar(title: Text('Dommers'), centerTitle: true),
            body: dommers != null
                ? dommers.isNotEmpty
                    ? ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, i) {
                          return DommerTile(dommer: dommers[i]);
                        })
                    : Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.block, size: 150),
                          Text('Necesitamos domiciliarios')
                        ],
                      ))
                : Container(),
            drawerEdgeDragWidth: 50,
            drawer: _drawer(),
            floatingActionButton: FloatingActionButton.extended(
                icon: Icon(Icons.bike_scooter),
                label: Text('Añadir dommer'),
                onPressed: () {
                  goToPage(1);
                })),
        AddDommer()
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
    _refresh();
  }

  void _refresh() {
    setState(() {});
  }

  void _load() async {
    personalInfo = await DatabaseService(uid: Provider.of<User>(context).uid)
        .personalInfo
        .first;
    fillUsers();
    fillDommers();
  }

  Drawer _drawer() {
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
            child: Icon(Icons.headset,
                color: Theme.of(context).primaryColor, size: 50)),
      ),
      ListTile(
          title: Text('Inicio'),
          selected: _page == 0,
          leading: Icon(Icons.home),
          onTap: () {
            setState(() {
              _page = 0;
              Navigator.pop(context);
            });
          }),
      ListTile(
          title: Text('Clientes'),
          selected: _page == 1,
          leading: Icon(Icons.people),
          onTap: () {
            setState(() {
              _page = 1;
              Navigator.pop(context);
            });
          }),
      ListTile(
          title: Text('Dommers'),
          selected: _page == 2,
          leading: Icon(Icons.bike_scooter),
          onTap: () {
            setState(() {
              _page = 2;
              Navigator.pop(context);
            });
          }),
      ListTile(
          title: Text('Cerrar sesión'),
          leading: Icon(Icons.logout),
          onTap: () => AuthService().signOut())
    ]));
  }
}

PageController _mainController = PageController();
void goToPage(int page) {
  _mainController.animateToPage(page,
      duration: Duration(milliseconds: 800), curve: Curves.bounceInOut);
}
