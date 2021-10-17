import 'dart:convert';

class PushNotificationModel {
  PushNotificationModel({
    required this.id,
    required this.type,
    required this.receiverId,
    required this.senderId,
    required this.title,
    required this.body,
    required this.tweetId,
  });

  final String id;
  final String type;
  final String receiverId;
  final String senderId;
  final String title;
  final String body;
  final String tweetId;

  factory PushNotificationModel.fromRawJson(String str) =>
      PushNotificationModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PushNotificationModel.fromJson(Map<dynamic, dynamic> json) =>
      PushNotificationModel(
        id: json["id"],
        type: json["type"],
        receiverId: json["receiverId"],
        senderId: json["senderId"],
        title: json["title"],
        body: json["body"],
        tweetId: json["tweetId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "receiverId": receiverId,
        "senderId": senderId,
        "title": title,
        "body": body,
        "tweetId": tweetId,
      };
}

class Notification {
  Notification({
    required this.body,
    required this.title,
  });

  final String body;
  final String title;

  factory Notification.fromRawJson(String str) =>
      Notification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Notification.fromJson(Map<dynamic, dynamic> json) => Notification(
        body: json["body"],
        title: json["title"],
      );

  Map<dynamic, dynamic> toJson() => {
        "body": body,
        "title": title,
      };
}
