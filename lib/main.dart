import 'models/user.dart';
import 'services/auth.dart';
import 'services/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dommer/services/notification_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  runApp(Domo());
}

class Domo extends StatefulWidget {
  @override
  _DomoState createState() => _DomoState();
}

get tokenId async => firebaseMessaging.getToken().then((t) => t);

final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

class _DomoState extends State<Domo> {
  void initState() {
    super.initState();
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      var provider = NotificationsProvider.instance;
      provider.addNotification();
      print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<> OnMessage:');
      _message(message);
    }, onResume: (Map<String, dynamic> message) async {
      print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<> OnResume:');
      _message(message);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<> OnLaunch:');
      _message(message);
    });
  }

  _message(Map<String, dynamic> message) {
    final notification = message['notification'];
    final data = message['data'];
    final String title = notification['title'];
    final String body = notification['body'];
    print('title: $title, body:$body, data:$data');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsProvider.instance,
      builder: (BuildContext context, Widget child) => child,
      child: StreamProvider<User>.value(
          value: AuthService().user,
          child: MaterialApp(
              home: Wrapper(),
              theme: ThemeData(
                appBarTheme: AppBarTheme(
                    textTheme: TextTheme(
                        headline6: TextStyle(
                            fontFamily: 'Provicali',
                            fontSize: 30,
                            letterSpacing: 3,
                            color: Theme.of(context).secondaryHeaderColor,
                            fontWeight: FontWeight.bold)),
                    color: Color.fromRGBO(103, 15, 128, 1),
                    elevation: 5),
                buttonTheme: ButtonThemeData(
                    buttonColor: Color.fromRGBO(103, 15, 128, 1),
                    textTheme: ButtonTextTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                iconTheme:
                    IconThemeData(color: Color.fromRGBO(103, 15, 128, 1)),
                textTheme: TextTheme(
                    bodyText2: TextStyle(fontFamily: 'Montserrat'),
                    button:
                        TextStyle(fontFamily: 'Provicali', letterSpacing: 1),
                    subtitle1: TextStyle(fontFamily: 'Montserrat')),
                accentColor: Colors.deepPurple,
                cursorColor: Color.fromRGBO(103, 15, 128, 1),
                primaryColor: Color.fromRGBO(103, 15, 128, 1),
                primaryColorDark: Color.fromRGBO(90, 10, 110, 1),
                primaryColorLight: Color.fromRGBO(150, 40, 180, 1),
                secondaryHeaderColor: Colors.white,
                scaffoldBackgroundColor: Colors.grey.shade100,
                textSelectionColor: Colors.purple[200],
                textSelectionHandleColor: Color.fromRGBO(103, 15, 128, 1),
                //canvasColor: Colors.transparent
              ),
              debugShowCheckedModeBanner: false)),
    );
  }
}
