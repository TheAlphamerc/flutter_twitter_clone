import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_twitter_clone/helper/shared_prefrence_helper.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/ui/page/common/locator.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;

class ProfileState extends ChangeNotifier {
  final String profileId;

  ProfileState(this.profileId) {
    databaseInit();
  }
  UserModel _userModel;

  String get userId => profileId;
  UserModel get userModel => _userModel;
  dabase.Query _profileQuery;
  StreamSubscription<Event> profileSubscription;

  UserModel get profileUserModel => _userModel;

  bool _isBusy = true;
  bool get isbusy => _isBusy;
  set loading(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  databaseInit() {
    try {
      if (_profileQuery == null) {
        _profileQuery = kDatabase.child("profile").child(profileId);
        profileSubscription = _profileQuery.onValue.listen(_onProfileChanged);
      }
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  Future<bool> isMyProfile() async {
    var user = await getIt<SharedPreferenceHelper>().getUserProfile();
    return user.userId == userId;
  }

  getProfileUser({String userProfileId}) {
    try {
      loading = true;
      // isbusy = true;
      // userProfileId = userProfileId == null ? user.uid : userProfileId;
      kDatabase
          .child("profile")
          .child(userProfileId)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            _userModel = UserModel.fromJson(map);
            // if (userProfileId == user.uid) {
            //   _userModel.isVerified = user.emailVerified;
            //   if (!user.emailVerified) {
            //     // Check if logged in user verified his email address or not
            //     reloadUser();
            //   }
            //   if (_userModel.fcmToken == null) {
            //     updateFCMToken();
            //   }
            // }

            Utility.logEvent('get_profile');
          }
        }
        loading = false;
        // isbusy = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  /// Follow / Unfollow user
  ///
  /// If `removeFollower` is true then remove user from follower list
  ///
  /// If `removeFollower` is false then add user to follower list
  followUser({bool removeFollower = false}) {
    /// `userModel` is user who is looged-in app.
    /// `profileUserModel` is user whoose profile is open in app.
    try {
      if (removeFollower) {
        /// If logged-in user `alredy follow `profile user then
        /// 1.Remove logged-in user from profile user's `follower` list
        /// 2.Remove profile user from logged-in user's `following` list
        profileUserModel.followersList.remove(userModel.userId);

        /// Remove profile user from logged-in user's following list
        userModel.followingList.remove(profileUserModel.userId);
        cprint('user removed from following list', event: 'remove_follow');
      } else {
        /// if logged in user is `not following` profile user then
        /// 1.Add logged in user to profile user's `follower` list
        /// 2. Add profile user to logged in user's `following` list
        if (profileUserModel.followersList == null) {
          profileUserModel.followersList = [];
        }
        profileUserModel.followersList.add(userModel.userId);
        // Adding profile user to logged-in user's following list
        if (userModel.followingList == null) {
          userModel.followingList = [];
        }
        userModel.followingList.add(profileUserModel.userId);
      }
      // update profile user's user follower count
      profileUserModel.followers = profileUserModel.followersList.length;
      // update logged-in user's following count
      userModel.following = userModel.followingList.length;
      kDatabase
          .child('profile')
          .child(profileUserModel.userId)
          .child('followerList')
          .set(profileUserModel.followersList);
      kDatabase
          .child('profile')
          .child(userModel.userId)
          .child('followingList')
          .set(userModel.followingList);
      cprint('user added to following list', event: 'add_follow');
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'followUser');
    }
  }

  /// Trigger when logged-in user's profile change or updated
  /// Firebase event callback for profile update
  void _onProfileChanged(Event event) {
    if (event.snapshot != null) {
      final updatedUser = UserModel.fromJson(event.snapshot.value);
      if (updatedUser.userId == userId) {
        _userModel = updatedUser;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileQuery.onValue.drain();
    profileSubscription.cancel();
    // _profileQuery.
    super.dispose();
  }
}
