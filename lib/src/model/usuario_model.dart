import 'package:firebase_database/firebase_database.dart';

class Usuario {
  String _id;
  String _user;
  String _password;
  String _genero;
  String _urlImage;
  String _nameImage;

  Usuario(this._id, this._user, this._password, this._genero, this._urlImage,
      this._nameImage);

  Usuario.map(dynamic obj) {
    this._user = obj['user'];
    this._password = obj['password'];
    this._genero = obj['genrer'];
    this._urlImage = obj['image'];
    this._genero = obj['nameimage'];
  }

  String get id => _id;
  String get user => _user;
  String get password => _password;
  String get genero => _genero;
  String get urlImage => _urlImage;
  String get nameImage => _nameImage;

  Usuario.fromSnapShot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _user = snapshot.value['user'];
    _password = snapshot.value['password'];
    _genero = snapshot.value['genrer'];
    _urlImage = snapshot.value['image'];
    _nameImage = snapshot.value['nameimage'];
  }
}
