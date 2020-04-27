class ChatMessage {
    String key;
    String senderId;
    String message;
    bool seen;
    String createdAt;
    String timeStamp;


    String senderName;
     String receiverId;

    ChatMessage({
        this.key,
        this.senderId,
        this.message,
        this.seen,
        this.createdAt,
        this.receiverId,
        this.senderName,
        this.timeStamp
    });

    factory ChatMessage.fromJson(Map<dynamic, dynamic> json) => ChatMessage(
        key: json["key"],
        senderId: json["sender_id"],
        message: json["message"],
        seen: json["seen"],
        createdAt: json["created_at"],
        timeStamp:json['timeStamp'],
        senderName: json["senderName"],
        receiverId: json["receiverId"]
    );

    Map<String, dynamic> toJson() => {
        "key": key,
        "sender_id": senderId,
        "message": message,
        "receiverId": receiverId,
        "seen": seen,
        "created_at": createdAt,
        "senderName": senderName,
        "timeStamp":timeStamp
    };
}
