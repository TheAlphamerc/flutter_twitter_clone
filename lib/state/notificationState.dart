// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../helper/utility.dart';
import '../model/feedModel.dart';
import '../model/notificationModel.dart';
import '../model/user.dart';
import '../resource/push_notification_service.dart';
import '../ui/page/common/locator.dart';
import 'appState.dart';

class NotificationState extends AppState {
  // String fcmToken;
  // FeedModel notificationTweetModel;

  // FcmNotificationModel notification;
  // String notificationSenderId;
  dabase.Query? query;
  List<UserModel> userList = [];

  List<NotificationModel>? _notificationList;

  addNotificationList(NotificationModel model) {
    _notificationList ??= <NotificationModel>[];

    if (!_notificationList!.any((element) => element.id == model.id)) {
      _notificationList!.insert(0, model);
    }
  }

  List<NotificationModel>? get notificationList => _notificationList;

  /// [Intitilise firebase notification kDatabase]
  Future<bool> databaseInit(String userId) {
    try {
      if (query != null) {
        query!.onValue.drain();
        query = null;
        _notificationList = null;
      }
      query = kDatabase.child("notification").child(userId);
      query!.onChildAdded.listen(_onNotificationAdded);
      query!.onChildChanged.listen(_onNotificationChanged);
      query!.onChildRemoved.listen(_onNotificationRemoved);

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Notification list] from firebase realtime database
  void getDataFromDatabase(String userId) {
    try {
      if (_notificationList != null) {
        return;
      }
      isBusy = true;
      kDatabase
          .child('notification')
          .child(userId)
          .once()
          .then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;
          if (map != null) {
            map.forEach((tweetKey, value) {
              var map = value as Map<dynamic, dynamic>;
              var model = NotificationModel.fromJson(tweetKey, map);
              addNotificationList(model);
            });
            _notificationList!
                .sort((x, y) => x.timeStamp!.compareTo(y.timeStamp!));
          }
        }
        isBusy = false;
      });
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get `Tweet` present in notification
  Future<FeedModel?> getTweetDetail(String tweetId) async {
    FeedModel _tweetDetail;
    var event = await kDatabase.child('tweet').child(tweetId).once();
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      _tweetDetail = FeedModel.fromJson(map);
      _tweetDetail.key = event.snapshot.key!;
      return _tweetDetail;
    } else {
      return null;
    }
  }

  /// get user who liked your tweet
  Future<UserModel?> getUserDetail(String userId) async {
    UserModel user;
    if (userList.isNotEmpty && userList.any((x) => x.userId == userId)) {
      return Future.value(userList.firstWhere((x) => x.userId == userId));
    }
    var event = await kDatabase.child('profile').child(userId).once();

    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      user = UserModel.fromJson(map);
      user.key = event.snapshot.key!;
      userList.add(user);
      return user;
    } else {
      return null;
    }
  }

  /// Remove notification if related Tweet is not found or deleted
  void removeNotification(String userId, String tweetkey) async {
    kDatabase.child('notification').child(userId).child(tweetkey).remove();
  }

  /// Trigger when somneone like your tweet
  void _onNotificationAdded(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var model = NotificationModel.fromJson(event.snapshot.key!, map);

      addNotificationList(model);
      // added notification to list
      print("Notification added");
      notifyListeners();
    }
  }

  /// Trigger when someone changed his like preference
  void _onNotificationChanged(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      notifyListeners();
      print("Notification changed");
    }
  }

  /// Trigger when someone undo his like on tweet
  void _onNotificationRemoved(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var model = NotificationModel.fromJson(event.snapshot.key!, map);
      // remove notification from list
      _notificationList!.removeWhere((x) => x.tweetKey == model.tweetKey);
      notifyListeners();
      print("Notification Removed");
    }
  }

  /// Initilise push notification services
  void initFirebaseService() {
    if (!getIt.isRegistered<PushNotificationService>()) {
      getIt.registerSingleton<PushNotificationService>(
          PushNotificationService(FirebaseMessaging.instance));
    }
  }

  @override
  void dispose() {
    getIt.unregister<PushNotificationService>();
    super.dispose();
  }
}
