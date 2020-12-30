import 'package:app_stories/src/connection/auth_services.dart';
import 'package:app_stories/src/model/authModel.dart';
import 'package:app_stories/src/model/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

final userReference = FirebaseDatabase.instance.reference().child('users');

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  AuthModel authModel = new AuthModel();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userName = "";
  String passWord = "";
  List<Usuario> users;
  //String _mensajeError = "";
  bool _showPassword = false;
  ScrollController _scrollController = new ScrollController();
  FocusNode _focus1 = new FocusNode();
  FocusNode _focus = new FocusNode();
  TextStyle estiloError = new TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.bold,
  );
  @override
  void initState() {
    super.initState();
    users = new List();
    _focus.addListener(_onFocusChange);
    //_onUserConsult = productReference.onValue.listen(_onUserConsulter);
  }

  void _onFocusChange() {
    setState(() {
      if (_focus.hasFocus) {
        print("Escroleamos");
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void requestFocus(BuildContext c, FocusNode f) {
    FocusScope.of(c).requestFocus(f);
  }

  @override
  void dispose() {
    super.dispose();
    //_onUserConsult.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Form(
        key: _formKey,
        child: Stack(
          children: <Widget>[
            Container(
              //padding: EdgeInsets.symmetric(vertical: 60),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.pink[300]],
                  
                ),
              ),
              child: Image.asset(
                "assets/logo.png",
                height: 200,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
            Transform.translate(
              offset: Offset(0, -80),
              child: Center(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Card(
                    color: Colors.yellow[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 260, bottom: 0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            focusNode: _focus1,
                            onEditingComplete: () {
                              requestFocus(context, _focus);
                            },
                            decoration: InputDecoration(labelText: "Usuario:"),
                            onSaved: (value) {
                              userName = value;
                            },
                            validator: (value) =>
                                value.isEmpty ? "campo vacío" : null,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            focusNode: _focus,
                            decoration: InputDecoration(
                                labelText: "Contraseña:",
                                suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    })),
                            obscureText: !_showPassword,
                            onSaved: (value) {
                              passWord = value;
                            },
                            validator: (value) =>
                                value.isEmpty ? "campo vacío" : null,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Theme(
                            data: Theme.of(context)
                                .copyWith(accentColor: Colors.white),
                            child: RaisedButton(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              color: Colors.blue,
                              textColor: Colors.white,
                              onPressed: () {
                                _login(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Iniciar Sesión",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (_loading)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: EdgeInsets.only(left: 20),
                                      child: CircularProgressIndicator(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            authModel.msgError,
                            style: estiloError,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(child: Text("¿Aún no tienes cuenta?")),
                              FlatButton(
                                textColor: Theme.of(context).accentColor,
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/register');
                                },
                                child: Text("Registrarse"),
                              ),
                              SizedBox(
                                height: 80,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    if (!_loading) {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        var isConnection = await checkInternetConnectivity(context);
        if (isConnection) {
          setState(() {
            _loading = true;
            authModel.msgError = "";
          });
          AlertDialog al = new AlertDialog();
          showDialog(context: context, child: al, barrierDismissible: false);
          var res = await AuthService()
              .loginUser(email: userName, password: passWord);
          if (res != null) {
            setState(() {
              authModel = res;
              _loading = false;
              if (authModel.state) {
                Navigator.of(context).popUntil((route) => route
                    .isFirst); // this line is the solution to pushreplacement not working
                Navigator.of(context).pushReplacementNamed("/home",
                    arguments: UserArguments(userName, passWord));
              } else {
                setState(() {
                  Navigator.pop(context);
                  authModel.msgError = "Usuario y/o contraseña incorrecta.";
                });
              }
            });
          }
        }
      }
    }
  }

  Future<bool> checkInternetConnectivity(BuildContext context) async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      _showDialogConfirm(
        context,
        "Error al entrar",
        "No se puede iniciar sesión. Comprueba tu conexión de red",
      );
      return false;
    } else if (result == ConnectivityResult.mobile) {
      print("Conexión establecida");
      return true;
    } else if (result == ConnectivityResult.wifi) {
      print("Conexión establecida");
      return true;
    }
  }

  void _showDialogConfirm(BuildContext context, String title, String info) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(info),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"))
            ],
          );
        });
  }
}
