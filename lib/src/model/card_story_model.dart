class CardStoryModel {
  String id, nomImage;
  String title, story, urlPicture, date, hour, who;
  bool isLogeduser = false;
  CardStoryModel(this.id, this.title, this.story, this.urlPicture, this.date,
      this.hour, this.who, this.nomImage,
      {this.isLogeduser});
}
