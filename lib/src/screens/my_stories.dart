import 'package:app_stories/src/components/cardStory.dart';
import 'package:app_stories/src/model/card_story_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:app_stories/src/screens/home_page.dart';

class MyStoriesPage extends StatefulWidget {
  final UserArguments us;
  MyStoriesPage(this.us);
  @override
  _MyStoriesPageState createState() => _MyStoriesPageState(us);
}

class _MyStoriesPageState extends State<MyStoriesPage> {
  UserArguments who;
  _MyStoriesPageState(this.who);
  List<CardStoryModel> cardStories = [];
  bool somethingInWeb = true;
  @override
  void initState() {
    super.initState();
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
        if (who.user == data[individualKey]['usuario'])
          cardStories.add(cardStory);
      }
      setState(() {
        print('Length: $cardStories.length');
      });
    }).whenComplete(() => setState(() {
          somethingInWeb = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mis Historias",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: somethingInWeb
            ? (Center(child: CircularProgressIndicator()))
            : cardStories.length == 0
                ? Center(
                    child: Text(
                    "Sin Hisorias... Comparte historias, cuentos, mitos, leyendas, anécdotas, y mucho más.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }
}
