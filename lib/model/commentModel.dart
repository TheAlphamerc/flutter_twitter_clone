
import 'user.dart';

class CommentModel {
  String key;
  String description;
  User user;
  int likeCount;
  int commentCount;
  String createdAt;
  String imagePath;

  CommentModel({this.key,this.description,this.user,this.likeCount,this.createdAt,this.imagePath,this.commentCount});
  toJson() {
    return {
      "description": description,
      "user": user.toJson(),
      "likeCount":likeCount ?? 0,
      "createdAt":createdAt,
      "imagePath":imagePath,
      "commentCount":commentCount ?? 0,
    };
  }
}