import 'dart:convert';

import 'package:flutter_twitter_clone/helper/enum.dart';
/// This model isn't used anywhere in code
/// Can be removed/deleted if required
class FcmNotificationModel {
    String clickAction;
    String id;
    String status;
    String type;
    String userId;
    String title;
    String body;
    String tweetId;

    FcmNotificationModel({
        this.clickAction,
        this.id,
        this.status,
        this.type,
        this.userId,
        this.title,
        this.body,
        this.tweetId,
    });

    factory FcmNotificationModel.fromRawJson(String str) => FcmNotificationModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory FcmNotificationModel.fromJson(Map<String, dynamic> json) {
      print("dat jbj bkkn,");
      return  FcmNotificationModel(
        clickAction: json["click_action"] == null ? null : json["click_action"],
        id: json["id"] == null ? null : json["id"],
        status: json["status"] == null ? null : json["status"],
        type: json["type"] == null ? null : json["type"],
        userId: json["userId"] == null ? null : json["userId"],
        title: json["title"] == null ? null : json["title"],
        body: json["body"] == null ? null : json["body"],
        tweetId: json["tweetId"] == null ? null : json["tweetId"],
    );}

    Map<String, dynamic> toJson() => {
        "click_action": clickAction == null ? null : clickAction,
        "id": id == null ? null : id,
        "status": status == null ? null : status,
        "type": type == null ? null : type,
        "userId": userId == null ? null : userId,
        "title": title == null ? null : title,
        "body": body == null ? null : body,
        "tweetId": tweetId == null ? null : tweetId,
    };

    NotificationType getNotificationType(){
    switch (type) {
      case 'NotificationType.Follow' : return NotificationType.Follow;
      case 'NotificationType.Message' : return NotificationType.Message;
      case 'NotificationType.NOT_DETERMINED' : return NotificationType.NOT_DETERMINED;
      case 'NotificationType.Reply' : return NotificationType.Reply;
      case 'NotificationType.Retweet' : return NotificationType.Retweet;
      default: return  NotificationType.NOT_DETERMINED;
    }}
}
