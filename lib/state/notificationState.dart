import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/notificationModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';

class NotificationState extends ChangeNotifier {
  List<NotificationModel> _notificationList;
  List<NotificationModel> get  notificationList => _notificationList;
  List<User> userList = [];
  dabase.Query query;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// [Intitilise firebase notification database]
  Future<bool> databaseInit(String userId) {
    try {
      if (query == null) {
        query = _database.reference().child("notification").child(userId);
        query.onChildAdded.listen(_onNotificationAdded);
        query.onChildChanged.listen(_onNotificationChanged);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error);
      return Future.value(false);
    }
  }

  /// get [Notification list] from firebase realtime database
  void getDataFromDatabase(String userId) {
    try {
      _notificationList = [];
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference
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
        notifyListeners();
      });
    } catch (error) {
      cprint(error);
    }
  }
  /// get notification `Tweet`
  Future<FeedModel> getTweetDetail(String tweetId) async {
    FeedModel _tweetDetail;
    final databaseReference = FirebaseDatabase.instance.reference();
    var snapshot = await databaseReference.child('feed').child(tweetId).once();
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
    if(userList.length > 0 && userList.any((x)=>x.userId == userId)){
        return Future.value(userList.firstWhere((x)=>x.userId == userId));
    }
    final databaseReference = FirebaseDatabase.instance.reference();
    var snapshot =
        await databaseReference.child('profile').child(userId).once();
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

  void _onNotificationAdded(Event event) {
    print("Notification added");
  }

  void _onNotificationChanged(Event event) {
    print("Notification changed");
  }
}
