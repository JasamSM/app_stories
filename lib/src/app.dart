import 'package:app_stories/src/model/card_story_model.dart';
import 'package:app_stories/src/screens/add_story.dart';
import 'package:app_stories/src/screens/detail_cardStory.dart';
import 'package:app_stories/src/screens/home_page.dart';
import 'package:app_stories/src/screens/login_page.dart';
import 'package:app_stories/src/screens/my_stories.dart';
import 'package:app_stories/src/screens/register_page.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryApp',
      initialRoute: '/',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.pink,
        primaryColorDark: Colors.blue[300],
        accentColor: Colors.blue[500],
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (BuildContext context) {
          switch (settings.name) {
            case "/":
              return LoginPage();
            case "/register":
              return RegisterPage();
            case "/home":
              UserArguments u = settings.arguments;
              return HomePage(u);
            case "/mystories":
              UserArguments u = settings.arguments;
              return MyStoriesPage(u);
            case "/add_story":
              String u = "";
              CardStoryModel c;
              try {
                u = settings.arguments;
              } catch (e) {
                c = settings.arguments;
              }
              return AddStory(u, cardEdit: c);
            case "/details":
              CardStoryModel card = settings.arguments;
              return DetailCardStory(card);
          }
        });
      },
    );
  }
}
