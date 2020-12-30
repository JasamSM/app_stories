import 'package:app_stories/src/model/card_story_model.dart';
import 'package:app_stories/src/screens/home_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DetailCardStory extends StatefulWidget {
  final CardStoryModel card;
  DetailCardStory(this.card);
  @override
  _DetailCardStoryState createState() => _DetailCardStoryState();
}

class _DetailCardStoryState extends State<DetailCardStory> {
  bool delete = false;
  GlobalKey<ScaffoldState> _scaffKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // print("el ide es: " + widget.card.id);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(
                widget.card.who,
                style: TextStyle(color: Colors.pink),
              ),
              expandedHeight: 320,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.card.urlPicture),
                )),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              pinned: true,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      if (widget.card.isLogeduser) {
                        Navigator.pop(context);
                        Navigator.of(context)
                            .pushNamed("/add_story", arguments: widget.card);
                      } else {
                        showSnackBar(context,
                            "Solo puedes editar tus historias", Colors.orange);
                      }
                    }),
                IconButton(
                    icon: !delete
                        ? Icon(Icons.delete)
                        : Container(
                            margin: EdgeInsets.all(3),
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator()),
                    onPressed: () {
                      if (widget.card.isLogeduser) {
                        _showDeleteDialog(context);
                      } else {
                        showSnackBar(context,
                            "Solo puedes eliminar tus historias", Colors.red);
                      }
                    }),
              ],
            ),
          ];
        },
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Fecha de publicación:"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.card.date,
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.card.hour,
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                widget.card.title,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Text(
                  widget.card.story,
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteStory(BuildContext context) async {
    final storyRef = FirebaseDatabase.instance.reference().child('Stories');
    final Reference imageRef =
        FirebaseStorage.instance.ref().child("Users CardsImage");
    var desertRef = imageRef.child(widget.card.nomImage);
    desertRef.delete().then((_) {
      print("Imagen Eliminada");
    });
    await storyRef.child(widget.card.id).remove().then((_) {
      setState(() {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed("/home",
            arguments: UserArguments(widget.card.who, "pass"));
      });
    });
  }

  _showDeleteDialog(BuildContext context) {
    AlertDialog alert = new AlertDialog(
      content: new Text("¿Realmente desea eliminar esta historia?"),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text(
              "No",
              style: new TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
            )),
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                delete = true;
                AlertDialog al = new AlertDialog();
                showDialog(
                    context: context, child: al, barrierDismissible: false);
              });
              _deleteStory(context);
            },
            child: new Text("Si",
                style: new TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red)))
      ],
    );
    showDialog(context: context, child: alert);
  }

  void showSnackBar(BuildContext context, String title, Color backColor) {
    _scaffKey.currentState.showSnackBar(SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: backColor,
      duration: new Duration(milliseconds: 900),
    ));
  }
}
