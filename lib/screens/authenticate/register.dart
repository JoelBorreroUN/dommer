import 'package:dommer/services/auth.dart';
import 'package:dommer/shared/constants.dart';
import 'package:dommer/shared/loading.dart';

import 'authentication.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

bool _loading = false; //, _premiumSwitch = true;
final AuthService _auth = AuthService();
final _formKey = GlobalKey<FormState>();
List<String> _roles = ['Repartidor', 'Soporte', 'Cliente'];
String _token = '';

class _RegisterState extends State<Register> {
  TextEditingController _nameController = TextEditingController(),
      _lastNameController = TextEditingController(),
      _phoneController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController(),
      _storeController = TextEditingController();
  String error = '', _role;
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    _loading = false;
    return _loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
                title: Text('Registrarme'),
                centerTitle: true,
                leading: _role == null
                    ? null
                    : IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          setState(() {
                            _role = null;
                          });
                        }),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(80)))),
            body: _role == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text('Continuar registro como:\n'),
                        RaisedButton(
                            elevation: 10,
                            color: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () {
                              setState(() {
                                _role = _roles[2];
                              });
                            },
                            child: Column(children: [
                              Container(
                                width: _size.width / 1.5,
                                height: _size.height / 20,
                              ),
                              Icon(Icons.store,
                                  size: _size.width / 5,
                                  color: Theme.of(context).primaryColor),
                              Text('Tienda',
                                  style: TextStyle(
                                      fontSize: 30, fontFamily: 'MontSerrat')),
                              Container(
                                width: _size.width / 1.5,
                                height: _size.height / 20,
                              )
                            ])),
                        Container(
                            width: _size.width, height: _size.height / 12),
                        RaisedButton(
                            elevation: 10,
                            color: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () {
                              setState(() {
                                _role = _roles[0];
                              });
                            },
                            child: Column(children: [
                              Container(
                                width: _size.width / 1.5,
                                height: _size.height / 20,
                              ),
                              Icon(Icons.bike_scooter,
                                  size: _size.width / 5,
                                  color: Theme.of(context).primaryColor),
                              Text(
                                'Repartidor',
                                style: TextStyle(
                                    fontSize: 30, fontFamily: 'MontSerrat'),
                              ),
                              Container(
                                width: _size.width / 1.5,
                                height: _size.height / 20,
                              )
                            ]))
                      ])
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(children: <Widget>[
                        TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Nombre',
                                icon: Icon(Icons.short_text)),
                            validator: (val) =>
                                val.isEmpty ? 'Ingrese su nombre' : null),
                        SizedBox(height: 10),
                        TextFormField(
                            controller: _lastNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: textInputDecoration.copyWith(
                                labelText: _role == 'Cliente'
                                    ? 'Dirección de tienda'
                                    : 'Apellido',
                                icon: Icon(_role == 'Cliente'
                                    ? Icons.edit_road
                                    : Icons.short_text)),
                            validator: (val) => val.isEmpty
                                ? _role == 'Cliente'
                                    ? 'Ingrese la dirección de la tienda'
                                    : 'Ingrese su apellido'
                                : null),
                        SizedBox(height: 10),
                        TextFormField(
                            maxLength: 10,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Teléfono', icon: Icon(Icons.phone)),
                            validator: (val) => val.isEmpty
                                ? 'Ingrese un número de contacto'
                                : null),
                        TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Correo electrónico',
                                icon: Icon(Icons.email)),
                            validator: (val) => val.isEmpty
                                ? 'Ingrese un correo electrónico'
                                : null),
                        /*_role == 'Cliente'
                            ? SwitchListTile(
                                title: Text(_premiumSwitch
                                    ? 'Cliente premium'
                                    : 'Cliente normal'),
                                subtitle: Text(_premiumSwitch
                                    ? 'Súper!'
                                    : 'Oww, otro será'),
                                secondary: Icon(
                                  Icons.star,
                                  color: _premiumSwitch
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                ),
                                value: _premiumSwitch,
                                onChanged: (s) {
                                  setState(() {
                                    _premiumSwitch = s;
                                  });
                                })
                            : */
                        TextFormField(
                            controller: _passwordController,
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Contraseña',
                                icon: Icon(Icons.visibility_off)),
                            obscureText: true,
                            validator: (val) => val.length < 8
                                ? 'Debe tener mínimo 8 caracteres'
                                : null),
                        /*Container(
                            width: 200,
                            child: DropdownButtonFormField(
                                value: _roles[_roles.indexOf(_role)],
                                icon: Icon(
                                    _role == 'Soporte'
                                        ? Icons.headset_mic
                                        : _role == 'Cliente'
                                            ? Icons.store
                                            : Icons.bike_scooter,
                                    color: Theme.of(context).primaryColor),
                                items: _roles
                                    .map((e) => DropdownMenuItem(
                                        child: Text('$e'), value: e))
                                    .toList(),
                                validator: (val) => val.toString() == ''
                                    ? 'Debe seleccionar un rol'
                                    : null,
                                onChanged: (s) {
                                  setState(() {
                                    _role = s.toString();
                                    _storeController.text =
                                        s.toString() == 'Cliente' ? '' : 'Domo';
                                  });
                                })),*/
                        TextField(
                            enabled: _role == 'Cliente',
                            controller: _storeController,
                            decoration: textInputDecoration.copyWith(
                              labelText: 'Tienda',
                              icon: Icon(Icons.store),
                            )),
                        RaisedButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                dynamic result;
                                setState(() => _loading = true);
                                result = _auth.registerEmail(
                                    _emailController.text,
                                    _passwordController.text,
                                    _nameController.text,
                                    _lastNameController.text,
                                    _phoneController.text,
                                    _role,
                                    _storeController.text,
                                    _token);
                                if (result == null) {
                                  setState(() {
                                    error = 'Por favor, verifique sus datos';
                                    _loading = false;
                                  });
                                }
                                /*else {
                                  if (_role == 'Cliente')
                                    showDialog(
                                        context: context,
                                        child: Dialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('\nÉxito!',
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: 20)),
                                                  Text(
                                                      '\n    ¡Su registro ha sido exitoso!    \n'),
                                                  RaisedButton(
                                                    onPressed: () async {
                                                      setState(() =>
                                                          _loading = true);
                                                      await _auth.signInEmail(
                                                          _emailController.text,
                                                          _passwordController
                                                              .text);
                                                      setState(() =>
                                                          _loading = false);
                                                      _nameController.text = '';
                                                      _lastNameController.text =
                                                          '';
                                                      _phoneController.text =
                                                          '';
                                                      _emailController.text =
                                                          '';
                                                      _passwordController.text =
                                                          '';
                                                      _storeController.text =
                                                          '';
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Ok!'),
                                                  )
                                                ]))
                                                );
                                }*/
                              }
                            },
                            child: Text('Registrarme',
                                style: TextStyle(color: Colors.white)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        Text(error,
                            style: TextStyle(color: Colors.red, fontSize: 14)),
                        Text('¿Ya tienes una cuenta?'),
                        FlatButton(
                            onPressed: () {
                              goToPage(0);
                            },
                            child: Text('Inicia sesión',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor)))
                      ]),
                    ),
                  ));
  }
}
