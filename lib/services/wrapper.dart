import 'package:dommer/main.dart';
import 'package:dommer/screens/client.dart';
import 'package:dommer/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dommer/models/user.dart';
import 'package:dommer/shared/loading.dart';
import 'package:dommer/models/delivery.dart';
import 'package:dommer/services/database.dart';
import 'package:dommer/screens/support/support.dart';
import 'package:dommer/screens/deliver/delivering.dart';
import 'package:dommer/screens/authenticate/authentication.dart';

User user;

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    //Return Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      DatabaseService db = DatabaseService(uid: user.uid);
      db.setToken(tokenId);
      return StreamBuilder<PersonalInfo>(
          stream: db.personalInfo,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return StreamProvider<List<Delivery>>.value(
                  value: DatabaseService().deliveries,
                  child: snapshot.data.role == 'Soporte'
                      ? Support()
                      : snapshot.data.role == 'Cliente'
                          ? Client()
                          : Delivering());
            } else {
              return Loading();
            }
          });
    }
  }
}
