import 'sign_in.dart';
import 'register.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

PageController _mainController = PageController();
void goToPage(int page) {
  _mainController.animateToPage(page,
      duration: Duration(milliseconds: 800), curve: Curves.bounceInOut);
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return PageView(
        controller: _mainController,
        physics: AlwaysScrollableScrollPhysics(),
        children: <Widget>[SignIn(), Register()]);
  }
}
