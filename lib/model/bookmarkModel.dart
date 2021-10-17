class BookmarkModel {
  String key;
  String tweetId;
  String createdAt;
  BookmarkModel({
    required this.key,
    required this.tweetId,
    required this.createdAt,
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
