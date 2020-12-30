import 'dart:io';
import 'package:app_stories/src/components/image_picker.dart';
import 'package:app_stories/src/connection/auth_services.dart';
import 'package:app_stories/src/model/authModel.dart';
import 'package:app_stories/src/screens/login_page.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _loading = false;
  bool _showPassword = false;
  File imageFile;
  int genero = 1;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffKey = GlobalKey<ScaffoldState>();
  String userName = "";
  String passWord = "";
  String urlImage = "";
  double size = 0;
  FocusNode _focus1 = new FocusNode();
  FocusNode _focus = new FocusNode();
  ScrollController _scrollController = new ScrollController();

  AuthModel authModel = new AuthModel();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _focus.hasFocus ? size = 80.0 : size = 0;
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
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        key: _scaffKey,
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: <Widget>[
            ImagePickerWidget(
                imageFile: this.imageFile,
                onImageSelected: (File file) {
                  setState(() {
                    imageFile = file;
                  });
                }),
            SizedBox(
              height: kToolbarHeight + 25,
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.white),
              ),
            ),
            Center(
              child: Transform.translate(
                offset: Offset(0, -40),
                child: Card(
                  color: Colors.yellow[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 260, bottom: 20),
                  child: ListView(
                    reverse: true,
                    shrinkWrap: true,
                    controller: _scrollController,
                    children: [
                      Padding(
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
                              decoration:
                                  InputDecoration(labelText: "Email:"),
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
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(child: Text("Género")),
                                Expanded(
                                  child: RadioListTile(
                                    title: Text("M"),
                                    value: 1,
                                    groupValue: genero,
                                    onChanged: (value) {
                                      setState(() {
                                        genero = value;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile(
                                    title: Text("F"),
                                    value: 2,
                                    groupValue: genero,
                                    onChanged: (value) {
                                      setState(() {
                                        genero = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(accentColor: Colors.white),
                              child: RaisedButton(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                color: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () {
                                  _register(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Registrar",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                            Text(authModel.msgError),
                            SizedBox(
                              height: size,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _register(BuildContext context) async {
    if (!_loading) {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        if (imageFile == null) {
          showSnackBar(
            context,
            "Seleccione una imagen por favor.",
            Colors.orange,
          );
          return;
        }
        var isConnection = await checkInternetConnectivity(context);
        if (isConnection) {
          setState(() {
            _loading = true;
          });
          AlertDialog al = new AlertDialog();
          showDialog(context: context, child: al, barrierDismissible: false);
          var res = await AuthService()
              .createUser(email: userName, password: passWord);
          if (res != null) {
            setState(() {
              authModel = res;
              _loading = false;
              if (authModel.state) {
                //guardamos la imagen
                final Reference imageRef =
                    FirebaseStorage.instance.ref().child("Users Image");
                var timeKey = DateTime.now();
                final UploadTask uploadTask = imageRef
                    .child(timeKey.toString() + ".jpg")
                    .putFile(imageFile);
                uploadTask.then((res) async {
                  urlImage = await res.ref.getDownloadURL();
                  //urlImage = imgurl.toString();
                  print(urlImage);
                  //guardamos los datos a la bd
                  DatabaseReference ref = FirebaseDatabase.instance.reference();
                  var data = {
                    "user": userName,
                    "password": passWord,
                    "image": urlImage,
                    "genrer": genero == 1 ? "masculino" : "femenino",
                    "nameimage": timeKey.toString() + ".jpg"
                  };
                  ref.child("Users").push().set(data);
                });
                Navigator.pop(context);
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Información"),
                        content: Text("Usuario registrado exitosamente."),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text("OK"))
                        ],
                      );
                    });
              } else {
                Navigator.pop(context);
              }
            });
          } //fin agregar usuario
        }
      }
    }
  }

  void showSnackBar(BuildContext context, String title, Color backColor) {
    _scaffKey.currentState.showSnackBar(SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
      ),
      backgroundColor: backColor,
    ));
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
