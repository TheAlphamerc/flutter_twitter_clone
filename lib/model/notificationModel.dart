import 'dart:convert';

import 'package:flutter_twitter_clone/model/user.dart';

class NotificationModel {
  String? id;
  String? tweetKey;
  String? updatedAt;
  String? createdAt;
  late String? type;
  Map<String, dynamic>? data;

  NotificationModel({
    this.id,
    this.tweetKey,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    required this.data,
  });

  NotificationModel.fromJson(String tweetId, Map<dynamic, dynamic> map) {
    id = tweetId;
    Map<String, dynamic> data = {};
    if (map.containsKey('data')) {
      data = json.decode(json.encode(map["data"])) as Map<String, dynamic>;
    }
    tweetKey = tweetId;
    updatedAt = map["updatedAt"];
    type = map["type"];
    createdAt = map["createdAt"];
    this.data = data;
  }
}

extension NotificationModelHelper on NotificationModel {
  UserModel get user => UserModel.fromJson(data);

  DateTime? get timeStamp => updatedAt != null || createdAt != null
      ? DateTime.tryParse(updatedAt ?? createdAt!)
      : null;
}
