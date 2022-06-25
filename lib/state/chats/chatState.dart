import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_twitter_clone/model/chatModel.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/appState.dart';

class ChatState extends AppState {
  late bool setIsChatScreenOpen; //!obsolete
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  List<ChatMessage>? _messageList;
  List<ChatMessage>? _chatUserList;
  UserModel? _chatUser;
  String serverToken = "<FCM SERVER KEY>";

  /// Get FCM server key from firebase project settings
  UserModel? get chatUser => _chatUser;
  set setChatUser(UserModel model) {
    _chatUser = model;
  }

  String? _channelName;
  Query? messageQuery;

  /// Contains list of chat messages on main chat screen
  /// List is sortBy message timeStamp
  /// Last message will be display on the bottom of screen
  List<ChatMessage>? get messageList {
    if (_messageList == null) {
      return null;
    } else {
      _messageList!.sort((x, y) => DateTime.parse(y.createdAt!)
          .toLocal()
          .compareTo(DateTime.parse(x.createdAt!).toLocal()));
      return _messageList;
    }
  }

  /// Contain list of users who have chat history with logged in user
  List<ChatMessage>? get chatUserList {
    if (_chatUserList == null) {
      return null;
    } else {
      return List.from(_chatUserList!);
    }
  }

  void databaseInit(String userId, String myId) async {
    _messageList = null;
    if (_channelName == null) {
      getChannelName(userId, myId);
    }
    kDatabase
        .child("chatUsers")
        .child(myId)
        .onChildAdded
        .listen(_onChatUserAdded);
    if (messageQuery == null || _channelName != getChannelName(userId, myId)) {
      messageQuery = kDatabase.child("chats").child(_channelName!);
      messageQuery!.onChildAdded.listen(_onMessageAdded);
      messageQuery!.onChildChanged.listen(_onMessageChanged);
    }
  }

  /// Fetch FCM server key from firebase Remote config
  /// FCM server key is stored in firebase remote config
  /// you have to add server key in firebase remote config
  /// To fetch this key go to project setting in firebase
  /// Click on `cloud messaging` tab
  /// Copy server key from `Project credentials`
  /// Now goto `Remote Config` section in Firebase
  /// Add [FcmServerKey]  as parameter key and below json in Default value
  ///  ``` json
  ///  {
  ///    "key": "FCM server key here"
  ///  } ```
  /// For more detail visit:- https://github.com/TheAlphamerc/flutter_twitter_clone/issues/28#issue-611695533
  /// For package detail check:-  https://pub.dev/packages/firebase_remote_config#-readme-tab-
  void getFCMServerKey() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    // await remoteConfig.
    var data = remoteConfig.getString('FcmServerKey');
    if (data.isNotEmpty) {
      serverToken = jsonDecode(data)["key"];
    } else {
      cprint("Please configure Remote config in firebase",
          errorIn: "getFCMServerKey");
    }
  }

  /// Fetch users list to who have ever engaged in chat message with logged-in user
  void getUserChatList(String userId) {
    try {
      kDatabase
          .child('chatUsers')
          .child(userId)
          .once()
          .then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        _chatUserList = <ChatMessage>[];
        if (snapshot.value != null) {
          var map = snapshot.value as Map?;
          if (map != null) {
            map.forEach((key, value) {
              var model = ChatMessage.fromJson(value);
              model.key = key;
              _chatUserList!.add(model);
            });
          }
          _chatUserList!.sort((x, y) {
            if (x.createdAt != null && y.createdAt != null) {
              return DateTime.parse(y.createdAt!)
                  .compareTo(DateTime.parse(x.createdAt!));
            } else {
              if (x.createdAt != null) {
                return 0;
              } else {
                return 1;
              }
            }
          });
        } else {
          _chatUserList = null;
        }
        notifyListeners();
      });
    } catch (error) {
      cprint(error);
    }
  }

  /// Fetch all chat messages
  /// `_channelName` is used as primary key for chat message table
  /// `_channelName` is created from  by combining first 5 letters from user ids of two users
  void getChatDetailAsync() async {
    try {
      kDatabase
          .child('chats')
          .child(_channelName!)
          .once()
          .then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        _messageList = <ChatMessage>[];
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;
          if (map != null) {
            map.forEach((key, value) {
              var model = ChatMessage.fromJson(value);
              model.key = key;
              _messageList!.add(model);
            });
          }
        } else {
          _messageList = null;
        }
        notifyListeners();
      });
    } catch (error) {
      cprint(error);
    }
  }

  /// Send message to other user
  void onMessageSubmitted(
    ChatMessage message,
    /*{UserModel myUser, UserModel secondUser}*/
  ) {
    print(chatUser!.userId);
    try {
      // if (_messageList == null || _messageList.length < 1) {
      kDatabase
          .child('chatUsers')
          .child(message.senderId)
          .child(message.receiverId)
          .set(message.toJson());

      kDatabase
          .child('chatUsers')
          .child(chatUser!.userId!)
          .child(message.senderId)
          .set(message.toJson());

      kDatabase
          .child('chats')
          .child(_channelName!)
          .push()
          .set(message.toJson());
      sendAndRetrieveMessage(message);
      Utility.logEvent('send_message', parameter: {});
    } catch (error) {
      cprint(error);
    }
  }

  /// Channel name is like a room name
  /// which save messages of two user uniquely in database
  String getChannelName(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    _channelName = '${list[0]}-${list[1]}';
    // cprint(_channelName); //2RhfE-5kyFB
    return _channelName!;
  }

  /// Method will trigger every time when you send/receive  from/to someone message.
  void _onMessageAdded(DatabaseEvent event) {
    _messageList ??= <ChatMessage>[];
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map;
      // ignore: unnecessary_null_comparison
      if (map != null) {
        var model = ChatMessage.fromJson(map);
        model.key = event.snapshot.key!;
        if (_messageList!.isNotEmpty &&
            _messageList!.any((x) => x.key == model.key)) {
          return;
        }
        _messageList!.add(model);
      }
    } else {
      _messageList = null;
    }
    notifyListeners();
  }

  void _onMessageChanged(DatabaseEvent event) {
    _messageList ??= <ChatMessage>[];
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      // ignore: unnecessary_null_comparison
      if (map != null) {
        var model = ChatMessage.fromJson(map);
        model.key = event.snapshot.key!;
        if (_messageList!.isNotEmpty &&
            _messageList!.any((x) => x.key == model.key)) {
          return;
        }
        _messageList!.add(model);
      }
    } else {
      _messageList = null;
    }
    notifyListeners();
  }

  void _onChatUserAdded(DatabaseEvent event) {
    _chatUserList ??= <ChatMessage>[];
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map;
      // ignore: unnecessary_null_comparison
      if (map != null) {
        var model = ChatMessage.fromJson(map);
        model.key = event.snapshot.key!;
        if (_chatUserList!.isNotEmpty &&
            _chatUserList!.any((x) => x.key == model.key)) {
          return;
        }
        _chatUserList!.add(model);
      }
    } else {
      _chatUserList = null;
    }
    notifyListeners();
  }

  // update last message on chat user list screen when main chat screen get closed.
  void onChatScreenClosed() {
    if (_chatUserList != null &&
        _chatUserList!.isNotEmpty &&
        _chatUserList!.any((element) => element.key == chatUser!.userId)) {
      var user = _chatUserList!.firstWhere((x) => x.key == chatUser!.userId);
      if (_messageList != null) {
        user.message = _messageList!.first.message;
        user.createdAt = _messageList!.first.createdAt; //;
        _messageList = null;
        notifyListeners();
      }
    }
  }

  /// Push notification will be sent to other user when you send him a message in chat.
  /// To send push notification make sure you have FCM `serverToken`
  void sendAndRetrieveMessage(ChatMessage model) async {
    // await firebaseMessaging.requestNotificationPermissions(
    //   const IosNotificationSettings(
    //       sound: true, badge: true, alert: true, provisional: false),
    // );
    if (chatUser!.fcmToken == null) {
      return;
    }

    var body = jsonEncode(<String, dynamic>{
      'notification': <String, dynamic>{
        'body': model.message,
        'title': "Message from ${model.senderName}"
      },
      'priority': 'high',
      'data': <String, dynamic>{
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done',
        "type": NotificationType.Message.toString(),
        "senderId": model.senderId,
        "receiverId": model.receiverId,
        "title": "title",
        "body": model.message,
      },
      'to': chatUser!.fcmToken
    });
    var response =
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'key=$serverToken',
            },
            body: body);
    if (response.reasonPhrase!.contains("INVALID_KEY")) {
      cprint(
        "You are using Invalid FCM key",
        errorIn: "sendAndRetrieveMessage",
      );
      return;
    }
    cprint(response.body.toString());
  }
}
