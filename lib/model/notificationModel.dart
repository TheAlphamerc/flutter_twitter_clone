class NotificationModel {
  String tweetKey;
  String updatedAt;
  String type;

  NotificationModel({
    this.tweetKey,
  });

  NotificationModel.fromJson(String tweetId, String updatedAt,String type) {
    tweetKey = tweetId;
    this.updatedAt = updatedAt;
    this.type = type;
  }

  Map<String, dynamic> toJson() => {
        "tweetKey": tweetKey == null ? null : tweetKey,
      };
}
