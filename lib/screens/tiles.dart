import 'package:flutter/material.dart';
import 'package:dommer/models/user.dart';
import 'package:dommer/models/delivery.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';

class DeliveryTile extends StatelessWidget {
  final Delivery delivery;
  final bool support;

  DeliveryTile({this.delivery, this.support});
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text(delivery.userName),
        subtitle: Text(delivery.toDo),
        leading: statusIcon(delivery.step, alertColor(delivery)),
        trailing: Text(support ? delivery.dommerName : delivery.status,
            style: TextStyle(color: alertColor(delivery))),
        children: [
          Text('Desde ${delivery.points.first} hasta ${delivery.points.last}'),
          Text('Asignado a ${delivery.dommerName}'),
          Text('${delivery.shortDate}'),
          Text('\$ ${delivery.price}',
              style: TextStyle(
                  color: Colors.green[700], fontWeight: FontWeight.bold)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            support
                ? RaisedButton.icon(
                    onPressed:
                        delivery.step > 0 ? () => delivery.toStep(false) : null,
                    icon: statusIcon(
                        delivery.step - (delivery.step > 0 ? 1 : 0),
                        alertColor(delivery)),
                    label: Text(delivery.backStep))
                : Container(),
            RaisedButton.icon(
                onPressed: delivery.step < 3
                    ? () => {
                          showDialog(
                              context: context,
                              child: Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(delivery.step == 0
                                                ? '¿Estás seguro que vas camino a recoger?'
                                                : delivery.step == 1
                                                    ? '¿Estás seguro que recogiste todo?'
                                                    : '¿Estás seguro que entregaste todo?'),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  OutlineButton(
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                      textColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      child: Text('Aún no'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      }),
                                                  RaisedButton(
                                                      child: Text('¡Seguro!'),
                                                      onPressed: () {
                                                        delivery.toStep(true);
                                                        Navigator.pop(context);
                                                      })
                                                ])
                                          ]))))
                        }
                    : null,
                icon: statusIcon(
                    delivery.step + (delivery.step < 3 ? 1 : 0), null),
                label: Text(delivery.nextStep))
          ])
        ]);
  }
}

class UserTile extends StatelessWidget {
  final PersonalInfo user;
  UserTile({this.user});
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text('${user.name}'),
        subtitle: Text(user.phone),
        leading: user.role == 'Premium' ? Icon(Icons.star) : Text(''),
        trailing: IconButton(
            icon: FaIcon(FontAwesomeIcons.whatsapp,
                color: user.phone.length == 10
                    ? Color.fromRGBO(37, 211, 102, 1)
                    : Colors.grey),
            onPressed: user.phone.length == 10
                ? () => FlutterOpenWhatsapp.sendSingleMessage(
                    '+57${user.phone}', 'Hola ${user.name}!')
                : null),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.store, color: Colors.grey),
            Text(user.store)
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.directions, color: Colors.grey),
            Text(user.address)
          ])
        ]);
  }
}

class DommerTile extends StatelessWidget {
  final PersonalInfo dommer;
  DommerTile({this.dommer});
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text('${dommer.name} ${dommer.lastName}'),
        subtitle: Text(dommer.phone),
        leading: dommer.active ? Icon(Icons.check_circle_outline) : Text(''),
        trailing: IconButton(
            icon: FaIcon(FontAwesomeIcons.whatsapp,
                color: dommer.phone.length == 10
                    ? Color.fromRGBO(37, 211, 102, 1)
                    : Colors.grey),
            onPressed: dommer.phone.length == 10
                ? () => FlutterOpenWhatsapp.sendSingleMessage(
                    '+57${dommer.phone}', 'Hola ${dommer.name}!')
                : null),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.store, color: Colors.grey),
            Text(dommer.store)
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.directions, color: Colors.grey),
            Text(
              dommer.active ? 'Activo' : 'Inactivo',
              style: TextStyle(
                  color: dommer.active ? Colors.green[700] : Colors.red[700]),
            )
          ])
        ]);
  }
}

Icon statusIcon(int status, Color color) {
  return [
    Icon(Icons.timer, color: color),
    Icon(Icons.store, color: color),
    Icon(Icons.alt_route, color: color),
    Icon(Icons.check, color: color)
  ][status];
}

Color alertColor(Delivery delivery) {
  if (delivery.status == 'Entregado') {
    return Colors.green[700];
  } else if (delivery.date
      .subtract(Duration(hours: 1))
      .isBefore(DateTime.now())) {
    return Colors.red[700];
  } else if (delivery.date
      .subtract(Duration(hours: 6))
      .isBefore(DateTime.now())) {
    return Colors.amber;
  } else {
    return Colors.grey;
  }
}
