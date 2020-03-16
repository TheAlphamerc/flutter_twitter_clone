class NotificationModel {
  String tweetKey;

  NotificationModel({
    this.tweetKey,
  });

  NotificationModel.fromJson(String tweetId) {
    tweetKey = tweetId;
  }

  Map<String, dynamic> toJson() => {
        "tweetKey": tweetKey == null ? null : tweetKey,
      };
}
