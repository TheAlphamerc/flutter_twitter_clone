import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/notificationModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/appState.dart';

class NotificationState extends AppState {
  dabase.Query query;
  List<User> userList = [];

  List<NotificationModel> _notificationList;

  List<NotificationModel> get notificationList => _notificationList;

  /// [Intitilise firebase notification kDatabase]
  Future<bool> databaseInit(String userId) {
    try {
      if (query == null) {
        query = kDatabase.child("notification").child(userId);
        query.onChildAdded.listen(_onNotificationAdded);
        query.onChildChanged.listen(_onNotificationChanged);
        query.onChildRemoved.listen(_onNotificationRemoved);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Notification list] from firebase realtime kDatabase
  void getDataFromDatabase(String userId) {
    try {
       loading = true;
      _notificationList = [];
      kDatabase
          .child('notification')
          .child(userId)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            map.forEach((tweetKey, value) {
              var model = NotificationModel.fromJson(tweetKey);
              _notificationList.add(model);
            });
          }
        }
       loading = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get `Tweet` present in notification
  Future<FeedModel> getTweetDetail(String tweetId) async {
    FeedModel _tweetDetail;
    var snapshot = await kDatabase.child('tweet').child(tweetId).once();
    if (snapshot.value != null) {
      var map = snapshot.value;
      _tweetDetail = FeedModel.fromJson(map);
      _tweetDetail.key = snapshot.key;
      return _tweetDetail;
    } else {
      return null;
    }
  }

  /// get user who liked your tweet
  Future<User> getuserDetail(String userId) async {
    User user;
    if (userList.length > 0 && userList.any((x) => x.userId == userId)) {
      return Future.value(userList.firstWhere((x) => x.userId == userId));
    }
    var snapshot =
        await kDatabase.child('profile').child(userId).once();
    if (snapshot.value != null) {
      var map = snapshot.value;
      user = User.fromJson(map);
      user.key = snapshot.key;
      userList.add(user);
      return user;
    } else {
      return null;
    }
  }
  /// Remove notification if related Tweet is not found or deleted
  void removeNotification(String userId, String tweetkey)async{
     kDatabase
            .child('notification')
            .child(userId)
            .child(tweetkey).remove();
  }
  /// Trigger when somneone like your tweet
  void _onNotificationAdded(Event event) {
    if (event.snapshot.value != null) {
      var model = NotificationModel.fromJson(event.snapshot.key);
      if (_notificationList == null) {
        _notificationList = List<NotificationModel>();
      }
      _notificationList.add(model);
      // added notification to list
      print("Notification added");
      notifyListeners();
    }
  }

  /// Trigger when someone changed his like preference
  void _onNotificationChanged(Event event) {
    if (event.snapshot.value != null) {
      var model = NotificationModel.fromJson(event.snapshot.key);
      //update notification list
      _notificationList
          .firstWhere((x) => x.tweetKey == model.tweetKey)
          .tweetKey = model.tweetKey;
      notifyListeners();
      print("Notification changed");
    }
  }

  /// Trigger when someone undo his like on tweet
  void _onNotificationRemoved(Event event) {
    if (event.snapshot.value != null) {
      var model = NotificationModel.fromJson(event.snapshot.key);
      // remove notification from list
      _notificationList.removeWhere((x) => x.tweetKey == model.tweetKey);
      notifyListeners();
      print("Notification Removed");
    }
  }
}
