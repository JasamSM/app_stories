import 'package:app_stories/src/components/cardStory.dart';
import 'package:app_stories/src/components/my_drawer.dart';
import 'package:app_stories/src/model/card_story_model.dart';
import 'package:app_stories/src/model/usuario_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserArguments us;
  HomePage(this.us);
  @override
  _HomePageState createState() => _HomePageState(us);
}

class _HomePageState extends State<HomePage> {
  UserArguments who;
  _HomePageState(this.who);
  List<CardStoryModel> cardStories = [];
  bool somethingInWeb = true;
  Usuario user;
  @override
  void initState() {
    super.initState();
    DatabaseReference cardRef =
        FirebaseDatabase.instance.reference().child("Stories");
    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child("Users");

    userRef.once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      for (var individualKey in keys) {
        if (who.user == data[individualKey]['user']) {
          user = Usuario(
            individualKey,
            data[individualKey]['user'],
            data[individualKey]['password'],
            data[individualKey]['genrer'],
            data[individualKey]['image'],
            data[individualKey]['nameimage'],
          );
        }
      }
    });

    cardRef.once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      cardStories.clear();
      for (var individualKey in keys) {
        CardStoryModel cardStory = CardStoryModel(
            individualKey,
            data[individualKey]['titulo'],
            data[individualKey]['historia'],
            data[individualKey]['image'],
            data[individualKey]['fecha'],
            data[individualKey]['hora'],
            data[individualKey]['usuario'],
            data[individualKey]['nomimagen']);
        cardStories.add(cardStory);
      }
      setState(() {
        print('Length: $cardStories.length');
      });
    }).whenComplete(() => setState(() {
          somethingInWeb = false;
        }));
  }

  _refrescarCards() {
    DatabaseReference cardRef =
        FirebaseDatabase.instance.reference().child("Stories");
    cardRef.once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;

      cardStories.clear();
      for (var individualKey in keys) {
        CardStoryModel cardStory = CardStoryModel(
            individualKey,
            data[individualKey]['titulo'],
            data[individualKey]['historia'],
            data[individualKey]['image'],
            data[individualKey]['fecha'],
            data[individualKey]['hora'],
            data[individualKey]['usuario'],
            data[individualKey]['nomimagen']);
        cardStories.add(cardStory);
      }
      setState(() {
        print('Length: $cardStories.length');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AppStories",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _refrescarCards();
              }),
        ],
      ),
      drawer: MyDrawer(user),
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: Container(
          child: somethingInWeb
              ? (Center(child: CircularProgressIndicator()))
              : cardStories.length == 0
                  ? Center(
                      child: Text(
                      "Sin Hisorias... Comparte historias, cuentos, mitos, leyendas, anécdotas, y mucho más.",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ))
                  : ListView.builder(
                      itemCount: cardStories.length,
                      itemBuilder: (_, index) {
                        return CardStoryWidget(
                          cardStories[index].id,
                          cardStories[index].title,
                          cardStories[index].story,
                          cardStories[index].urlPicture,
                          cardStories[index].date,
                          cardStories[index].hour,
                          cardStories[index].who,
                          cardStories[index].nomImage,
                          userlogin: who.user,
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed("/add_story", arguments: who.user);
        },
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Cerrar Sesión"),
            content: Text("¿Estás seguro que quieres cerrar tu sesión?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("CANCELAR")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pushReplacementNamed("/");
                  },
                  child: Text("ACEPTAR")),
            ],
          );
        });
  }
}

class UserArguments {
  final String user;
  final String pwd;
  UserArguments(this.user, this.pwd);
}
