import 'package:flutter_twitter_clone/model/user.dart';

class FeedModel {
  String key;
  String parentkey;
  String childRetwetkey;
  String description;
  String userId;
  int likeCount;
  List<String> likeList;
  int commentCount;
  int retweetCount;
  String createdAt;
  String imagePath;
  List<String> tags;
  List<String> replyTweetKeyList;
  UserModel user;
  FeedModel(
      {this.key,
      this.description,
      this.userId,
      this.likeCount,
      this.commentCount,
      this.retweetCount,
      this.createdAt,
      this.imagePath,
      this.likeList,
      this.tags,
      this.user,
      this.replyTweetKeyList,
      this.parentkey,
      this.childRetwetkey});
  toJson() {
    return {
      "userId": userId,
      "description": description,
      "likeCount": likeCount,
      "commentCount": commentCount ?? 0,
      "retweetCount": retweetCount ?? 0,
      "createdAt": createdAt,
      "imagePath": imagePath,
      "likeList": likeList,
      "tags": tags,
      "replyTweetKeyList": replyTweetKeyList,
      "user": user == null ? null : user.toJson(),
      "parentkey": parentkey,
      "childRetwetkey": childRetwetkey
    };
  }

  FeedModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    description = map['description'];
    userId = map['userId'];
    //  name = map['name'];
    //  profilePic = map['profilePic'];
    likeCount = map['likeCount'] ?? 0;
    commentCount = map['commentCount'];
    retweetCount = map["retweetCount"] ?? 0;
    imagePath = map['imagePath'];
    createdAt = map['createdAt'];
    imagePath = map['imagePath'];
    //  username = map['username'];
    user = UserModel.fromJson(map['user']);
    parentkey = map['parentkey'];
    childRetwetkey = map['childRetwetkey'];
    if (map['tags'] != null) {
      tags = List<String>();
      map['tags'].forEach((value) {
        tags.add(value);
      });
    }
    if (map["likeList"] != null) {
      likeList = List<String>();

      final list = map['likeList'];

      /// In new tweet db schema likeList is stored as a List<String>()
      ///
      if (list is List) {
        map['likeList'].forEach((value) {
          if (value is String) {
            likeList.add(value);
          }
        });
        likeCount = likeList.length ?? 0;
      }

      /// In old database tweet db schema likeList is saved in the form of map
      /// like list map is removed from latest code but to support old schema below code is required
      /// Once all user migrated to new version like list map support will be removed
      else if (list is Map) {
        list.forEach((key, value) {
          likeList.add(value["userId"]);
        });
        likeCount = list.length;
      }
    } else {
      likeList = [];
      likeCount = 0;
    }
    if (map['replyTweetKeyList'] != null) {
      map['replyTweetKeyList'].forEach((value) {
        replyTweetKeyList = List<String>();
        map['replyTweetKeyList'].forEach((value) {
          replyTweetKeyList.add(value);
        });
      });
      commentCount = replyTweetKeyList.length;
    } else {
      replyTweetKeyList = [];
      commentCount = 0;
    }
  }

  bool get isValidTweet {
    bool isValid = false;
    if (description != null &&
        description.isNotEmpty &&
        this.user != null &&
        this.user.userName != null &&
        this.user.userName.isNotEmpty) {
      isValid = true;
    } else {
      print("Invalid Tweet found. Id:- $key");
    }
    return isValid;
  }
}
