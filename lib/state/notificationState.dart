import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/notificationModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/appState.dart';

class NotificationState extends AppState {
  String fcmToken;
  NotificationType _notificationType = NotificationType.NOT_DETERMINED;
  String notificationReciverId, notificationTweetId;
  List<FeedModel> notificationTweetList;
  NotificationType get notificationType => _notificationType;
  set setNotificationType(NotificationType type) {
    _notificationType = type;
  }

  static final CollectionReference _userCollection =
      kfirestore.collection(USERS_COLLECTION);
  // FcmNotificationModel notification;
  String notificationSenderId;
  dabase.Query query;
  List<UserModel> userList = [];
  StreamSubscription<QuerySnapshot> notificationSubscription;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  List<NotificationModel> _notificationList;

  List<NotificationModel> get notificationList => _notificationList;

  /// [Intitilise firebase notification kDatabase]
  Future<bool> databaseInit(String userId) {
    try {
      // if (query == null) {
      // query = kDatabase.child("notification").child(userId);

      notificationSubscription = _userCollection
          .doc(userId)
          .collection(NOTIFICATION_COLLECTION)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        if (snapshot.docChanges.isEmpty) {
          return;
        }
        if (snapshot.docChanges.first.type == DocumentChangeType.added) {
          _onNotificationAdded(snapshot.docChanges.first.doc);
        } else if (snapshot.docChanges.first.type ==
            DocumentChangeType.removed) {
          _onNotificationRemoved(snapshot.docChanges.first.doc);
        } else if (snapshot.docChanges.first.type ==
            DocumentChangeType.modified) {
          _onNotificationChanged(snapshot.docChanges.first.doc);
        }
      });

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  void unsubscribeNotifications(String userId) {
    notificationSubscription.cancel();
  }

  /// get [Notification list] from firebase realtime database
  void getDataFromDatabase(String userId) {
    try {
      // if(_notificationList != null && _notificationList.isNotEmpty){
      //   return;
      // }
      loading = true;
      _notificationList = [];
      _userCollection
          .doc(userId)
          .collection(NOTIFICATION_COLLECTION)
          .get()
          .then((QuerySnapshot querySnapshot) {
        // _feedlist = List<FeedModel>();
        if (querySnapshot != null && querySnapshot.docs.isNotEmpty) {
          for (var i = 0; i < querySnapshot.docs.length; i++) {
            var model = NotificationModel.fromJson(
              querySnapshot.docs[i].data(),
            );
            model.tweetKey = querySnapshot.docs[i].id;
            if (_notificationList.any((x) => x.tweetKey == model.tweetKey)) {
              continue;
            }
            _notificationList.add(model);
          }
          _notificationList.sort((x, y) => DateTime.parse(y.updatedAt)
              .compareTo(DateTime.parse(x.updatedAt)));
        }
        loading = false;
        notifyListeners();
      });
      // kDatabase
      //     .child('notification')
      //     .child(userId)
      //     .once()
      //     .then((DataSnapshot snapshot) {
      //   if (data != null) {
      //     var map = data;
      //     if (map != null) {
      //       map.forEach((tweetKey, value) {
      //         var model = NotificationModel.fromJson(
      //           tweetKey,
      //         );
      //         _notificationList.add(model);
      //       });
      //       _notificationList.sort((x, y) {
      //         if (x.updatedAt != null && y.updatedAt != null) {
      //           return DateTime.parse(y.updatedAt)
      //               .compareTo(DateTime.parse(x.updatedAt));
      //         } else if (x.updatedAt != null) {
      //           return 1;
      //         } else
      //           return 0;
      //       });
      //     }
      //   }
      //   loading = false;
      // });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get `Tweet` present in notification
  Future<FeedModel> getTweetDetail(String tweetId) async {
    FeedModel _tweetDetail;
    var snapshot =
        await kfirestore.collection(TWEET_COLLECTION).doc(tweetId).get();

    var map = snapshot.data();
    if (map != null) {
      _tweetDetail = FeedModel.fromJson(map);
      _tweetDetail.key = snapshot.id;
    }
    if (_tweetDetail == null) {
      cprint("Tweet not found " + tweetId);

      /// remove notification from firebase db if tweet in not available or deleted.
    }
    if (tweetId == "AOrRB0EHIbFSAev2WX4P") {
      print("dsfsfgg");
    }
    return _tweetDetail;
  }

  /// get user who liked your tweet
  Future<UserModel> getuserDetail(String userId) async {
    UserModel user;

    /// if user already available in userlist then get user data from list
    /// It reduce api load
    if (userList.length > 0 && userList.any((x) => x.userId == userId)) {
      return Future.value(userList.firstWhere((x) => x.userId == userId));
    }

    /// If user sata not available in userlist then fetch user data from firestore
    var snapshot =
        await kfirestore.collection(USERS_COLLECTION).doc(userId).get();

    var map = snapshot.data();
    if (map != null) {
      user = UserModel.fromJson(map);
      user.key = snapshot.id;

      /// Add user data to userlist
      /// Next time user data can be get from this list
      userList.add(user);
    }
    return user;
  }

  /// Remove notification if related Tweet is not found or deleted
  void removeNotification(String userId, String tweetkey) async {
    print("removeNotification " + tweetkey);
    _userCollection
        .doc(userId)
        .collection(NOTIFICATION_COLLECTION)
        .doc(tweetkey)
        .delete();
    // kDatabase.child('notification').child(userId).child(tweetkey).remove();
  }

  /// Trigger when somneone like your tweet
  void _onNotificationAdded(DocumentSnapshot event) {
    if (event.data() != null) {
      var model = NotificationModel.fromJson(event.data());
      model.tweetKey = event.id;
      // event.data()["updatedAt"], event.data()["type"]);
      if (_notificationList == null) {
        _notificationList = List<NotificationModel>();
      }
      if (_notificationList.any((x) => x.tweetKey == model.tweetKey)) {
        return;
      }
      _notificationList.insert(0, model);
      // _notificationList.add(model);
      // added notification to list
      print("Notification added");
      notifyListeners();
    }
  }

  // /// Trigger when someone changed his like preference
  void _onNotificationChanged(DocumentSnapshot event) {
    if (event.data() != null) {
      var model = NotificationModel.fromJson(event.data());
      model.tweetKey = event.id;
      //update notification list
      _notificationList
          .firstWhere((x) => x.tweetKey == model.tweetKey)
          .tweetKey = model.tweetKey;
      notifyListeners();
      cprint("Notification changed");
    }
  }

  /// Trigger when someone undo his like on tweet
  void _onNotificationRemoved(DocumentSnapshot event) {
    if (event.data() != null) {
      var model = NotificationModel.fromJson(event.data());
      model.tweetKey = event.id;
      // remove notification from list
      _notificationList.removeWhere((x) => x.tweetKey == model.tweetKey);
      if (_notificationList.isEmpty) {
        _notificationList = null;
      }
      notifyListeners();
      cprint("Notification Removed");
    }
  }

  /// Configure notification services
  void initfirebaseService() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // print("onMessage: $message");
        print(message['data']);
        notifyListeners();
      },
      onLaunch: (Map<String, dynamic> message) async {
        cprint("Notification ", event: "onLaunch");
        var data = message['data'];
        // print(message['data']);
        notificationSenderId = data["senderId"];
        notificationReciverId = data["receiverId"];
        notificationReciverId = data["receiverId"];
        if (data["type"] == "NotificationType.Mention") {
          setNotificationType = NotificationType.Mention;
        } else if (data["type"] == "NotificationType.Message") {
          setNotificationType = NotificationType.Message;
        }
        notifyListeners();
      },
      onResume: (Map<String, dynamic> message) async {
        cprint("Notification ", event: "onResume");
        var data = message['data'];
        // print(message['data']);
        notificationSenderId = data["senderId"];
        notificationReciverId = data["receiverId"];
        if (data["type"] == "NotificationType.Mention") {
          setNotificationType = NotificationType.Mention;
        } else if (data["type"] == "NotificationType.Message") {
          setNotificationType = NotificationType.Message;
        }
        notifyListeners();
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      fcmToken = token;
      print(token);
    });
  }
}
