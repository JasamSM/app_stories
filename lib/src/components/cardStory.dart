import 'package:app_stories/src/model/card_story_model.dart';
import 'package:flutter/material.dart';

class CardStoryWidget extends StatelessWidget {
  final String id, nomImage;
  final String title, story, urlPicture, date, hour, who;
  final String userlogin;
  CardStoryWidget(this.id, this.title, this.story, this.urlPicture, this.date,
      this.hour, this.who, this.nomImage,
      {this.userlogin});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Card(
          elevation: 10,
          margin: EdgeInsets.all(14.0),
          child: Container(
            padding: EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  who,
                  style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.blue[500],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: Text(
                        hour,
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Center(
                  child: Image.network(
                    urlPicture,
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  story,
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.justify,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showDetail(BuildContext context) {
    bool loged = userlogin == who;

    Navigator.pushNamed(
      context,
      '/details',
      arguments: CardStoryModel(
          id, title, story, urlPicture, date, hour, who, nomImage,
          isLogeduser: loged),
    );
  }
}
