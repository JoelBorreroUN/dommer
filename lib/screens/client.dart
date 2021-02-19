import 'package:dommer/models/user.dart';
import 'package:dommer/services/auth.dart';
import 'package:dommer/services/database.dart';
import 'package:dommer/services/wrapper.dart';
import 'package:dommer/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dommer/models/delivery.dart';

import 'support/add_delivery.dart';
import 'tiles.dart';

class Client extends StatefulWidget {
  @override
  _ClientState createState() => _ClientState();
}

List<Delivery> _deliveries = [];
PersonalInfo personalInfo;
DateTime _date = DateTime.now().add(Duration(minutes: 30));
String e = '';
int _price = 0, _page = 0;

class _ClientState extends State<Client> {
  List<TextEditingController> _points = [
        new TextEditingController(
            text: personalInfo != null ? personalInfo.address : 'nulo'),
        new TextEditingController()
      ],
      _descriptions = [
        new TextEditingController(
            text:
                'Recoger en ${personalInfo != null ? personalInfo.store : 'nula'}'),
        new TextEditingController()
      ],
      _transactions = [
        new TextEditingController(text: '0'),
        new TextEditingController(text: '0')
      ];
  @override
  Widget build(BuildContext context) {
    _load();
    _deliveries = Provider.of<List<Delivery>>(context);
    _deliveries.retainWhere((d) => d.userId == personalInfo.uid);
    return PageView(
        controller: _mainController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Scaffold(
              appBar: AppBar(
                  title: Text('${personalInfo.store}'), centerTitle: true),
              body: _deliveries != null
                  ? _deliveries.isNotEmpty
                      ? ListView.builder(
                          itemCount: _deliveries.length,
                          itemBuilder: (context, i) {
                            return DeliveryTile(
                                delivery: _deliveries[i], support: true);
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
              floatingActionButton: FloatingActionButton.extended(
                  icon: Icon(Icons.add_road),
                  label: Text('Añadir ruta'),
                  onPressed: () {
                    goToPage(1);
                  }),
              drawer: Drawer(
                  child: ListView(children: [
                UserAccountsDrawerHeader(
                  accountName: Text(personalInfo != null
                      ? '${personalInfo.name} ${personalInfo.lastName}'
                      : ''),
                  accountEmail:
                      Text(personalInfo != null ? '${personalInfo.role}' : ''),
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
                    title: Text('Cerrar sesión'),
                    leading: Icon(Icons.logout),
                    onTap: () => AuthService().signOut())
              ])),
              drawerEdgeDragWidth: 50),
          Scaffold(
              appBar: AppBar(
                  title: Text('Añadir pedido'),
                  centerTitle: true,
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () => goToPage(0))),
              body: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  flex: 2,
                                  child: TextField(
                                      decoration: textInputDecoration.copyWith(
                                          labelText: 'Desde'),
                                      controller: _points.first)),
                              Flexible(
                                  flex: 1,
                                  child: TextField(
                                    decoration: textInputDecoration.copyWith(
                                        labelText: int.parse(
                                                    _transactions.first.text) >=
                                                0
                                            ? 'Cobra'
                                            : 'Paga'),
                                    controller: _transactions.first,
                                    keyboardType: TextInputType.number,
                                  )),
                              Switch(
                                  value:
                                      int.parse(_transactions.first.text) >= 0,
                                  activeColor: Colors.green[700],
                                  inactiveThumbColor: Colors.red[700],
                                  inactiveTrackColor: Colors.red[200],
                                  onChanged: (b) {
                                    setState(() {
                                      _transactions.first.text = (-1 *
                                              int.parse(
                                                  _transactions.first.text))
                                          .toString();
                                    });
                                  })
                            ]),
                        TextField(
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Descripción', hintText: 'Opcional'),
                            controller: _descriptions.first),
                        _buildDivider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  flex: 2,
                                  child: TextField(
                                      decoration: textInputDecoration.copyWith(
                                          labelText: 'Hasta'),
                                      controller: _points.last)),
                              Flexible(
                                  flex: 1,
                                  child: TextField(
                                    decoration: textInputDecoration.copyWith(
                                        labelText: int.parse(
                                                    _transactions.last.text) >=
                                                0
                                            ? 'Cobra'
                                            : 'Paga'),
                                    controller: _transactions.last,
                                    keyboardType: TextInputType.number,
                                  )),
                              Switch(
                                  value:
                                      int.parse(_transactions.last.text) >= 0,
                                  activeColor: Colors.green[700],
                                  inactiveThumbColor: Colors.red[700],
                                  inactiveTrackColor: Colors.red[200],
                                  onChanged: (b) {
                                    setState(() {
                                      _transactions.last.text = (-1 *
                                              int.parse(
                                                  _transactions.last.text))
                                          .toString();
                                    });
                                  })
                            ]),
                        TextField(
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Descripción', hintText: 'Opcional'),
                            controller: _descriptions.last),
                        Row(children: [
                          Text(
                              'Fecha de envío: ${_date.day}/${_date.month}/${_date.year} ${_date.hour}:${_date.minute}'),
                          IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context))
                        ]),
                        Text(e, style: TextStyle(color: Colors.red)),
                        RaisedButton.icon(
                            icon: Icon(Icons.add_road),
                            label: Text('Añadir'),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_points.first.text == '' ||
                                  _points.last.text == '') {
                                setState(() => e =
                                    'Verifique los puntos origen y destino');
                              } else if (_transactions.first.text == '' ||
                                  _transactions.last.text == '') {
                                setState(() => e = 'Verifique los precios');
                              } else {
                                DatabaseService().addDelivery(
                                    _points.map((e) => e.text).toList(),
                                    _descriptions.map((e) => e.text).toList(),
                                    _transactions
                                        .map((e) => int.parse(e.text))
                                        .toList(),
                                    user.uid,
                                    '',
                                    _date);
                                goToPage(0);
                              }
                            }),
                        SizedBox(height: 100),
                        Text('Precio'),
                        Text('$_price',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20))
                      ])))
        ]);
  }

  void _load() async {
    personalInfo = await DatabaseService(uid: Provider.of<User>(context).uid)
        .personalInfo
        .first;
  }

  void _selectDate(BuildContext context) async {
    _date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 7))) ??
        _date;
    TimeOfDay _time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now()) ??
            TimeOfDay.now();
    _date = _date.add(Duration(hours: _time.hour, minutes: _time.minute));
  }
}

PageController _mainController = PageController();
void goToPage(int page) {
  _mainController.animateToPage(page,
      duration: Duration(milliseconds: 800), curve: Curves.bounceInOut);
}

Container _buildDivider() {
  return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      height: 1,
      color: Colors.grey.shade500);
}
