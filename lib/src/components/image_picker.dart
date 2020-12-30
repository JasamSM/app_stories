import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef OnImageSelected = Function(File imageFile);

class ImagePickerWidget extends StatelessWidget {
  final File imageFile;
  final String urlEdit;
  final OnImageSelected onImageSelected;
  ImagePickerWidget(
      {@required this.imageFile, @required this.onImageSelected, this.urlEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.black87, Colors.pink[300]],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          image: imageFile != null
              ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover)
              : urlEdit != null
                  ? DecorationImage(
                      image: NetworkImage(urlEdit), fit: BoxFit.cover)
                  : null),
      child: IconButton(
        icon: Icon(Icons.camera_alt),
        onPressed: () {
          _showPickerOptions(context);
        },
        iconSize: 90,
        color: Colors.white,
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camara"),
                onTap: () {
                  Navigator.pop(context);
                  _showPickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text("Galería"),
                onTap: () {
                  Navigator.pop(context);
                  _showPickImage(context, ImageSource.gallery);
                },
              ),
            ],
          );
        });
  }

  void _showPickImage(BuildContext context, source) async {
    var image = await ImagePicker().getImage(source: source);

    this.onImageSelected(File(image.path));
  }
}

