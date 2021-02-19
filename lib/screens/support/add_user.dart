import 'package:dommer/shared/constants.dart';

import 'support.dart';
import 'package:flutter/material.dart';
import 'package:dommer/services/auth.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

bool _premiumSwitch = false, _loading = false;
final AuthService _auth = AuthService();
final _formKey = GlobalKey<FormState>();

class _AddUserState extends State<AddUser> {
  TextEditingController _nameController = TextEditingController(),
      _phoneController = TextEditingController(),
      _addressController = TextEditingController(),
      _storeController = TextEditingController(text: 'Domo');
  String error = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Añadir usuario'),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios), onPressed: () => goToPage(0)),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: textInputDecoration.copyWith(
                          labelText: 'Nombre', icon: Icon(Icons.short_text)),
                      validator: (val) =>
                          val.isEmpty ? 'Ingrese su nombre' : null),
                  SizedBox(height: 10),
                  TextFormField(
                      maxLength: 10,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: textInputDecoration.copyWith(
                          labelText: 'Teléfono', icon: Icon(Icons.phone)),
                      validator: (val) =>
                          val.isEmpty ? 'Ingrese un número de contacto' : null),
                  TextFormField(
                      controller: _addressController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: textInputDecoration.copyWith(
                          labelText: 'Dirección de tienda',
                          icon: Icon(Icons.edit_road)),
                      validator: (val) => val.isEmpty
                          ? 'Ingrese la dirección de la tienda'
                          : null),
                  SwitchListTile(
                      title: Text(_premiumSwitch
                          ? 'Cliente premium'
                          : 'Cliente normal'),
                      subtitle:
                          Text(_premiumSwitch ? 'Súper!' : 'Oww, otro será'),
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
                      }),
                  TextField(
                      controller: _storeController,
                      decoration: textInputDecoration.copyWith(
                        labelText: 'Tienda',
                        icon: Icon(Icons.store),
                      )),
                  RaisedButton(
                      child:
                          Text('Añadir', style: TextStyle(color: Colors.white)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          dynamic result;
                          setState(() => _loading = true);
                          result = _auth.registerClient(
                              _nameController.text,
                              _phoneController.text,
                              _addressController.text,
                              _storeController.text,
                              _premiumSwitch ? 'Premium' : 'Normal');
                          if (result == null) {
                            setState(() {
                              error = 'Por favor, verifique sus datos';
                              _loading = false;
                            });
                          } else {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                child: Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('\nÉxito!',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 20)),
                                          Text(
                                              '\n    El cliente se ha agegado correctamente    \n'),
                                          RaisedButton(
                                              onPressed: () {
                                                _nameController.text = '';
                                                _phoneController.text = '';
                                                _addressController.text = '';
                                                _storeController.text = '';
                                                Navigator.pop(context);
                                                goToPage(0);
                                              },
                                              child: Text('Ok!'))
                                        ])));
                          }
                        }
                      }),
                  Text(error, style: TextStyle(color: Colors.red, fontSize: 14))
                ]))));
  }
}
