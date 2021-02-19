import 'package:flutter/material.dart';
import 'package:dommer/screens/support/support.dart';

class AddDommer extends StatefulWidget {
  @override
  _AddDommerState createState() => _AddDommerState();
}

class _AddDommerState extends State<AddDommer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir dommer'),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), onPressed: () => goToPage(0)),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [Text('')],
      )),
    );
  }
}
