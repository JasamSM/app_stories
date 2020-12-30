import 'dart:io';
import 'package:app_stories/src/components/image_picker.dart';
import 'package:app_stories/src/model/card_story_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';

class AddStory extends StatefulWidget {
  final String us;
  final CardStoryModel cardEdit;
  AddStory(this.us, {this.cardEdit});
  @override
  _AddStoryState createState() => _AddStoryState(us);
}

class _AddStoryState extends State<AddStory> {
  String who;
  _AddStoryState(this.who);
  File imageFile;
  bool _loading = false;
  double size = 0;
  FocusNode _focus1 = new FocusNode();
  FocusNode _focus = new FocusNode();

  String operation = "compartida";
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffKey = GlobalKey<ScaffoldState>();
  String titulo = "", historia = "", fecha, hora, usuario, urlImage;
  String id, nameImg;
  bool editingCard = false;
  double translate = -30;
  ScrollController _scrollController = new ScrollController();
  void _onFocusChange() {
    setState(() {
      _focus.hasFocus ? size = 100.0 : size = 0;
      _focus.hasFocus ? translate = -100 : translate = -30;
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
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    editingCard = widget.cardEdit != null;
    if (editingCard) {
      titulo = widget.cardEdit.title;
      historia = widget.cardEdit.story;
      fecha = widget.cardEdit.date;
      hora = widget.cardEdit.hour;
      usuario = widget.cardEdit.who;
      urlImage = widget.cardEdit.urlPicture;
      id = widget.cardEdit.id;
      nameImg = widget.cardEdit.nomImage;
      operation = "actualizada";
      who = widget.cardEdit.who;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("user: " + who);
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
              },
              urlEdit: widget.cardEdit != null ? urlImage : null,
            ),
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
                offset: Offset(0, translate),
                child: Card(
                  color: Colors.yellow[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 260, bottom: 20),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              focusNode: _focus1,
                              onEditingComplete: () {
                                requestFocus(context, _focus);
                              },
                              initialValue: titulo,
                              decoration: InputDecoration(labelText: "Título:"),
                              onSaved: (value) {
                                titulo = value;
                              },
                              validator: (value) =>
                                  value.isEmpty ? "campo vacío" : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              focusNode: _focus,
                              initialValue: historia,
                              decoration: InputDecoration(
                                labelText: "Historia:",
                              ),
                              minLines: 4,
                              maxLines: 7,
                              onSaved: (value) {
                                historia = value;
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                color: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () => _saveStory(context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      editingCard
                                          ? "Actualizar Historia"
                                          : "Añadir Historia",
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
                            SizedBox(
                              height: size,
                            )
                          ],
                        ),
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

  void _saveStory(BuildContext context) async {
    if (!_loading) {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        if (imageFile == null && !editingCard) {
          showSnackBar(
            context,
            "Seleccione una imagen por favor.",
            Colors.orange,
          );
          return;
        }
        setState(() {
          _loading = true;
        });
        AlertDialog al = new AlertDialog();
        showDialog(context: context, child: al, barrierDismissible: false);
        setState(() {
          if (editingCard) {
            if (imageFile != null) {
              //si edita y cambia la imagen, eliminamos la actual
              final Reference imageRef =
                  FirebaseStorage.instance.ref().child("Users CardsImage");
              var desertRef = imageRef.child(nameImg);
              desertRef.delete().then((_) {
                print("Imagen Eliminada");
                _guardarImagen(context);
              });
            } else {
              _guardarInDatabase();
              setState(() {
                _loading = false;
              });
              Navigator.pop(context);
              _showDialogConfirm(context, operation);
            }
          } else {
            _guardarImagen(context);
          }
        });
      }
    }
  }

  _guardarInDatabase() {
    //guardamos los datos a la bd
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat('d MMM, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');

    fecha = formatDate.format(dbTimeKey);
    hora = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var data = {
      "titulo": titulo,
      "historia": historia,
      "image": urlImage,
      "fecha": fecha,
      "hora": hora,
      "usuario": who,
      "nomimagen": nameImg
    };
    editingCard
        ? ref.child("Stories").child(id).update(data)
        : ref.child("Stories").push().set(data);
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

  void _showDialogConfirm(BuildContext context, String s) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Información"),
            content: Text("Historia $s exitosamente."),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacementNamed("/home",
                        arguments: UserArguments(who, "pass"));
                  },
                  child: Text("OK"))
            ],
          );
        });
  }

  void _guardarImagen(BuildContext context) {
    //guardamos la imagen
    final Reference imageRef =
        FirebaseStorage.instance.ref().child("Users CardsImage");
    var timeKey = DateTime.now();
    final UploadTask uploadTask =
        imageRef.child(timeKey.toString() + ".jpg").putFile(imageFile);

    uploadTask.then((res) async {
      urlImage = await res.ref.getDownloadURL();
      //urlImage = imgurl.toString();
      nameImg = timeKey.toString() + ".jpg";
      print(urlImage);

      //guardamos datos en bd
      _guardarInDatabase();
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
      _showDialogConfirm(context, operation);
    });
  }
}
