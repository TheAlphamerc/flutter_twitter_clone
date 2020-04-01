import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_twitter_clone/model/chatModel.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/appState.dart';

class ChatState extends AppState {
  bool setIsChatScreenOpen;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  List<ChatMessage> _messageList;
  List<User> _chatUserList;
  User _chatUser;
  User get chatUser => _chatUser;
  set setChatUser(User model) {
    _chatUser = model;
  }

  String _channelName;
  Query messageQuery;

  List<ChatMessage> get messageList {
    if (_messageList == null) {
      return null;
    } else {
      _messageList.sort((x, y) =>
          DateTime.parse(x.createdAt).toLocal().compareTo(DateTime.parse(y.createdAt).toLocal()));
      _messageList.reversed;
      _messageList = _messageList.reversed.toList();
      return List.from(_messageList);
    }
  }

  List<User> get chatUserList {
    if (_chatUserList == null) {
      return null;
    } else {
      return List.from(_chatUserList);
    }
  }

  void databaseInit(String userId, String myId) {
    _messageList = null;
    if (_channelName == null) {
      getChannelName(userId, myId);
    }
    _database
        .reference()
        .child("chatUsers")
        .child(myId)
        .onChildAdded
        .listen(_onChatUserAdded);
    if (messageQuery == null || _channelName != getChannelName(userId, myId)) {
      messageQuery = _database.reference().child("chats").child(_channelName);
      messageQuery.onChildAdded.listen(_onMessageAdded);
      messageQuery.onChildChanged.listen(_onMessageChanged);
    }
  }

  void getUserchatList(String userId) {
    try {
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference
          .child('chatUsers')
          .child(userId)
          .once()
          .then((DataSnapshot snapshot) {
        _chatUserList = List<User>();
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            map.forEach((key, value) {
              var model = User.fromJson(value);
              model.key = key;
              _chatUserList.add(model);
            });
          }
        } else {
          _chatUserList = null;
        }
        notifyListeners();
      });
    } catch (error) {
      cprint(error);
    }
  }

  void getchatDetailAsync() {
    try {
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference
          .child('chats')
          .child(_channelName)
          .once()
          .then((DataSnapshot snapshot) {
        _messageList = List<ChatMessage>();
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            map.forEach((key, value) {
              var model = ChatMessage.fromJson(value);
              model.key = key;
              _messageList.add(model);
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

  void onMessageSubmitted(ChatMessage message, {User myUser, User secondUser}) {
    // print('2RhfEy0MPzdfOp9MtqtSDABau2d25kyFBK0vfDc3AkF6a8zfaudQOHw12RhfEy0MPzdfOp9MtqtSDABau2d25kyFBK0vfDc3AkF6a8zfaudQOHw1');
    try {
      if (_messageList == null || _messageList.length < 1) {
        _database
            .reference()
            .child('chatUsers')
            .child(message.senderId)
            .child(message.receiverId)
            .set(secondUser.toJson());

        _database
            .reference()
            .child('chatUsers')
            .child(secondUser.userId)
            .child(message.senderId)
            .set(myUser.toJson());
      }
      _database
          .reference()
          .child('chats')
          .child(_channelName)
          .push()
          .set(message.toJson());
      logEvent('send_message');
    } catch (error) {
      cprint(error);
    }
  }

  String getChannelName(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    _channelName = '${list[0]}-${list[1]}';
    // cprint(_channelName); //2RhfE-5kyFB
    return _channelName;
  }

  void _onMessageAdded(Event event) {
    if (_messageList == null) {
      _messageList = List<ChatMessage>();
    }
    if (event.snapshot.value != null) {
      var map = event.snapshot.value;
      if (map != null) {
        var model = ChatMessage.fromJson(map);
        model.key = event.snapshot.key;
        if (_messageList.length > 0 &&
            _messageList.any((x) => x.key == model.key)) {
          return;
        }
        _messageList.add(model);
      }
    } else {
      _messageList = null;
    }
    notifyListeners();
  }

  void _onMessageChanged(Event event) {
    if (_messageList == null) {
      _messageList = List<ChatMessage>();
    }
    if (event.snapshot.value != null) {
      var map = event.snapshot.value;
      if (map != null) {
        var model = ChatMessage.fromJson(map);
        model.key = event.snapshot.key;
        if (_messageList.length > 0 &&
            _messageList.any((x) => x.key == model.key)) {
          return;
        }
        _messageList.add(model);
      }
    } else {
      _messageList = null;
    }
    notifyListeners();
  }

  void _onChatUserAdded(Event event) {
    if (_chatUserList == null) {
      _chatUserList = List<User>();
    }
    if (event.snapshot.value != null) {
      var map = event.snapshot.value;
      if (map != null) {
        var model = User.fromJson(map);
        model.key = event.snapshot.key;
        if (_chatUserList.length > 0 &&
            _chatUserList.any((x) => x.key == model.key)) {
          return;
        }
        _chatUserList.add(model);
      }
    } else {
      _chatUserList = null;
    }
    notifyListeners();
  }

  void dispose() {
    // messageQuery = null;
    _messageList = null;
    // _channelName = null;
  }
}
