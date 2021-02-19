import 'authentication.dart';
import 'package:flutter/material.dart';
import 'package:dommer/services/auth.dart';
import 'package:dommer/shared/loading.dart';
import 'package:dommer/shared/constants.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  //Text field state
  String _email = '', _password = '', _error = '';
  FocusNode _f1 = FocusNode();
  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
                title: Text('Iniciar sesión'),
                centerTitle: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(80)))),
            body: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      SizedBox(height: 20),
                      TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Correo electrónico',
                              icon: Icon(Icons.email)),
                          validator: (val) => val.isEmpty
                              ? 'Ingrese un correo electrónico'
                              : null,
                          onChanged: (val) {
                            setState(() => _email = val);
                          },
                          onEditingComplete: () =>
                              FocusScope.of(context).requestFocus(_f1)),
                      TextFormField(
                          focusNode: _f1,
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Contraseña',
                              icon: Icon(Icons.visibility_off)),
                          obscureText: true,
                          validator: (val) => val.length < 8
                              ? 'La contraseña debe tener mínimo 8 caracteres'
                              : null,
                          onChanged: (val) {
                            setState(() => _password = val);
                          }),
                      SizedBox(height: 50),
                      RaisedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() => _loading = true);
                              dynamic result =
                                  await _auth.signInEmail(_email, _password);
                              if (result == null) {
                                setState(() {
                                  _error = 'Por favor, verifique sus datos';
                                  _loading = false;
                                });
                              }
                            }
                          },
                          child: Text('Iniciar sesión',
                              style: TextStyle(color: Colors.white)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      Text(_error,
                          style: TextStyle(color: Colors.red, fontSize: 14)),
                      Text('\n\n\n¿Aún no tienes una cuenta?'),
                      FlatButton(
                          onPressed: () {
                            goToPage(1);
                          },
                          child: Text('Crear cuenta',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor))),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RaisedButton.icon(
                                onPressed: () async {
                                  setState(() => _loading = true);
                                  await _auth.signInEmail(
                                      'freddy@gm.co', 'co@gm.co');
                                  setState(() => _loading = false);
                                },
                                icon: Icon(Icons.bike_scooter),
                                label: Text('Freddy')),
                            RaisedButton.icon(
                                onPressed: () async {
                                  setState(() => _loading = true);
                                  await _auth.signInEmail(
                                      'marco@gm.co', 'co@gm.co');
                                  setState(() => _loading = false);
                                },
                                icon: Icon(Icons.bike_scooter),
                                label: Text('Marcos'))
                          ]),
                      RaisedButton.icon(
                          onPressed: () async {
                            setState(() => _loading = true);
                            await _auth.signInEmail('co@gm.co', 'co@gm.co');
                            setState(() => _loading = false);
                          },
                          icon: Icon(Icons.headset_mic),
                          label: Text('Andrea')),
                      RaisedButton.icon(
                          onPressed: () async {
                            setState(() => _loading = true);
                            await _auth.signInEmail('dj@gm.co', 'co@gm.co');
                            setState(() => _loading = false);
                          },
                          icon: Icon(Icons.headset_mic),
                          label: Text('Don Jacobo'))
                    ]))));
  }
}
