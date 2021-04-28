import 'dart:convert';

class PushNotificationModel {
  PushNotificationModel({
    this.notification,
    this.data,
  });

  final Notification notification;
  final Data data;

  factory PushNotificationModel.fromRawJson(String str) =>
      PushNotificationModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PushNotificationModel.fromJson(Map<dynamic, dynamic> json) =>
      PushNotificationModel(
        notification: Notification.fromJson(json["notification"]),
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "notification": notification.toJson(),
        "data": data.toJson(),
      };
}

class Data {
  Data({
    this.id,
    this.type,
    this.receiverId,
    this.senderId,
    this.title,
    this.body,
    this.tweetId,
  });

  final String id;
  final String type;
  final String receiverId;
  final String senderId;
  final String title;
  final String body;
  final String tweetId;

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<dynamic, dynamic> json) => Data(
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
    this.body,
    this.title,
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
