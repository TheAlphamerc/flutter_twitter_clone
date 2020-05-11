class NotificationModel {
  String tweetKey;
  String updatedAt;
  String type;

  NotificationModel({
    this.tweetKey,
  });

  NotificationModel.fromJson(Map<String, dynamic> json, ) {
    // tweetKey = tweetId;
    this.updatedAt = json["updatedAt"];
    this.type = json["type"];
  }

  Map<String, dynamic> toJson() => {
        "tweetKey": tweetKey == null ? null : tweetKey,
      };
}
