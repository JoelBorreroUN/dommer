import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dommer/shared/constants.dart';
import 'package:dommer/services/database.dart';
import 'package:dommer/screens/support/support.dart';

class AddDelivery extends StatefulWidget {
  @override
  _AddDeliveryState createState() => _AddDeliveryState();
}

class _AddDeliveryState extends State<AddDelivery> {
  List<TextEditingController> _points = [
        new TextEditingController(),
        new TextEditingController()
      ],
      _descriptions = [
        new TextEditingController(),
        new TextEditingController()
      ],
      _transactions = [
        new TextEditingController(text: '0'),
        new TextEditingController(text: '0')
      ];
  String e = '', _user = '', _dommer = '';
  int _price = 0;
  TextEditingController _userController = TextEditingController(),
      _dommerController = TextEditingController();
  DateTime _date = DateTime.now().add(Duration(minutes: 30));
  @override
  Widget build(BuildContext context) {
    fillUsers();
    fillDommers();
    return Scaffold(
        appBar: AppBar(
          title: Text('Añadir ruta'),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                FocusScope.of(context).unfocus();
                goToPage(0);
              }),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ExpansionTile(
                      title: TextField(
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Cliente'),
                          controller: _userController,
                          onChanged: (s) {
                            if (s == '') {
                              _user = '';
                            }
                            setState(() {});
                          }),
                      trailing: Icon(Icons.person_search),
                      children: _usersList()),
                  ExpansionTile(
                      title: TextField(
                          decoration:
                              textInputDecoration.copyWith(labelText: 'Dommer'),
                          controller: _dommerController,
                          onChanged: (s) {
                            if (s == '') {
                              _dommer = '';
                            }
                            setState(() {});
                          }),
                      trailing: Icon(Icons.bike_scooter),
                      children: _dommersList()),
                  _buildDivider(),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                              labelText:
                                  int.parse(_transactions.first.text) >= 0
                                      ? 'Cobra'
                                      : 'Paga'),
                          controller: _transactions.first,
                          keyboardType: TextInputType.number,
                        )),
                    Switch(
                        value: int.parse(_transactions.first.text) >= 0,
                        activeColor: Colors.green[700],
                        inactiveThumbColor: Colors.red[700],
                        inactiveTrackColor: Colors.red[200],
                        onChanged: (b) {
                          setState(() {
                            _transactions.first.text =
                                (-1 * int.parse(_transactions.first.text))
                                    .toString();
                          });
                        })
                  ]),
                  TextField(
                      decoration: textInputDecoration.copyWith(
                          labelText: 'Descripción', hintText: 'Opcional'),
                      controller: _descriptions.first),
                  _buildDivider(),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                              labelText: int.parse(_transactions.last.text) >= 0
                                  ? 'Cobra'
                                  : 'Paga'),
                          controller: _transactions.last,
                          keyboardType: TextInputType.number,
                        )),
                    Switch(
                        value: int.parse(_transactions.last.text) >= 0,
                        activeColor: Colors.green[700],
                        inactiveThumbColor: Colors.red[700],
                        inactiveTrackColor: Colors.red[200],
                        onChanged: (b) {
                          setState(() {
                            _transactions.last.text =
                                (-1 * int.parse(_transactions.last.text))
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
                        if (_userController.text == '') {
                          setState(() => e = 'Verifique el usuario');
                        } else if (_dommerController.text == '') {
                          setState(() => e = 'Verifique el domiciliario');
                        } else if (_points.first.text == '' ||
                            _points.last.text == '') {
                          setState(() =>
                              e = 'Verifique los puntos origen y destino');
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
                              _user,
                              _dommer,
                              _date);
                          goToPage(0);
                        }
                      }),
                  SizedBox(height: 100),
                  Text('Precio sugerido'),
                  Text('$_price',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                ])),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.calculate), onPressed: _showCalculator));
  }

  List<Widget> _usersList() {
    return users
        .where((u) =>
            '${u.name} ${u.phone} ${u.store}'
                .toLowerCase()
                .contains(_userController.text.toLowerCase()) &&
            _user != u.uid)
        .map((u) => ListTile(
            title: Text(u.name),
            subtitle: Text(u.phone),
            trailing: Text(u.store),
            onTap: () {
              setState(() {
                _user = u.uid;
                _userController.text = u.name;
                _points.first.text = u.address;
              });
            }))
        .toList();
  }

  List<Widget> _dommersList() {
    return dommers
        .where((u) =>
            '${u.name} ${u.lastName} ${u.phone} ${u.store}'
                .toLowerCase()
                .contains(_dommerController.text.toLowerCase()) &&
            _dommer != u.uid)
        .map((u) => ListTile(
            title: Text('${u.name} ${u.lastName}'),
            subtitle: Text(u.phone),
            onTap: () => setState(() {
                  _dommer = u.uid;
                  _dommerController.text = '${u.name} ${u.lastName}';
                })))
        .toList();
  }

  void _refresh() {
    setState(() {});
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
    _refresh();
  }

  void _showCalculator() {
    TextEditingController _distanceController = TextEditingController();
    bool _normal = true;
    int _calculatePrice(bool normal, double distance) {
      return (normal
              ? distance > 1
                  ? (distance - 1) * 900 + 3000
                  : 3000
              : distance > 1
                  ? (distance - 1) * 1000 + 4000
                  : 4000)
          .round();
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Calculadora de precios\n',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 20)),
                          Row(children: [
                            Flexible(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: textInputDecoration.copyWith(
                                    labelText: 'Distancia'),
                                controller: _distanceController,
                              ),
                            ),
                            Icon(Icons.local_taxi,
                                color: _normal
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor),
                            Switch(
                                value: _normal,
                                onChanged: (b) {
                                  setState(() {
                                    _normal = b;
                                  });
                                }),
                            Icon(Icons.bike_scooter,
                                color: _normal
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey)
                          ]),
                          RaisedButton(
                              child: Text('Calcular'),
                              onPressed: () {
                                try {
                                  _price = _calculatePrice(_normal,
                                      double.parse(_distanceController.text));
                                  Navigator.pop(context);
                                  _refresh();
                                } catch (e) {}
                              })
                        ])));
          });
        });
  }
}

Container _buildDivider() {
  return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      height: 1,
      color: Colors.grey.shade500);
}
