import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: RadialGradient(colors: [
              Theme.of(context).primaryColorDark,
              Theme.of(context).primaryColorDark,
              Theme.of(context).primaryColor,
            ])),
            child: Stack(alignment: Alignment.center, children: <Widget>[
              SpinKitRing(
                  color: Theme.of(context).primaryColor,
                  lineWidth: 30,
                  size: MediaQuery.of(context).size.width / 2),
              Text('domo',
                  style: TextStyle(
                      fontFamily: 'Provicali',
                      fontSize: 50,
                      letterSpacing: 3,
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.only(top: 250),
                  child: Text('Estamos preparando todo para ti...',
                      style: TextStyle(
                          fontFamily: 'MontSerrat',
                          fontSize: 12,
                          color: Theme.of(context).secondaryHeaderColor)))
            ])));
  }
}
