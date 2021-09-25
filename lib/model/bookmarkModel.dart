class BookmarkModel {
  String key;
  String tweetId;
  String createdAt;
  BookmarkModel({
    this.key,
    this.tweetId,
    this.createdAt,
  });

  factory BookmarkModel.fromJson(Map<dynamic, dynamic> json) => BookmarkModel(
        key: json["tweetId"],
        tweetId: json["tweetId"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "tweetId": tweetId,
        "created_at": createdAt,
      };
}
