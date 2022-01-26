import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/shared_prefrence_helper.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:flutter_twitter_clone/ui/page/common/locator.dart';

enum StateType { following, follower }

class FollowListState extends AppState {
  FollowListState(StateType type) {
    isBusy = true;
    getIt<SharedPreferenceHelper>().getUserProfile().then((user) {
      if (user != null) {
        _currentUser = user;
        isBusy = false;
      }
    });
    stateType = type;
  }

  UserModel? _currentUser;
  late StateType stateType;

  /// Follow / Unfollow user
  Future<void> followUser(UserModel secondUser) async {
    bool isfollwing = isFollowing(secondUser);

    /// `_currentUser` is user who is logged-in  app.
    /// `secondUser` is user whoose profile is open in app.
    try {
      if (isfollwing) {
        /// If current user alredy followed secondUser user then
        /// 1.Remove current user from second user's `follower` list
        /// 2.Remove second user from current user's `following` list
        secondUser.followersList!.remove(_currentUser!.userId);

        /// Remove second user from current user user's following list
        _currentUser!.followingList!.remove(secondUser.userId);
        cprint('user removed from following list');
      } else {
        /// if current user is not following second user then
        /// 1.Add current user to second user's `follower` list
        /// 2. Add second user to current user's `following` list
        secondUser.followersList ??= [];
        secondUser.followersList!.add(_currentUser!.userId!);
        // Adding second user to current user's following list
        _currentUser!.followingList ??= [];
        addFollowNotification(secondUser.userId!);
        _currentUser!.followingList!.add(secondUser.userId!);

        cprint('user added from following list');
      }

      // update second user's follower count
      secondUser.followers = secondUser.followersList!.length;
      // update current user's following count
      _currentUser!.following = _currentUser!.followingList!.length;

      /// Update other user profile
      kDatabase
          .child('profile')
          .child(secondUser.userId!)
          .child('followerList')
          .set(secondUser.followersList);

      /// update current user profile
      kDatabase
          .child('profile')
          .child(_currentUser!.userId!)
          .child('followingList')
          .set(_currentUser!.followingList);
      cprint('Operation Success');
      // await getIt<SharedPreferenceHelper>().saveUserProfile(_currentUser!);

      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'followUser');
    }
  }

  /// Check if user followerlist contain your or not
  /// If your id exist in follower list it mean you are following him
  bool isFollowing(UserModel user) {
    if (_currentUser!.followingList != null &&
        _currentUser!.followingList!.any((x) => x == user.userId)) {
      return true;
    }
    return false;
  }

  void addFollowNotification(String profileId) {
    // Sends notification to user who created tweet
    // UserModel owner can see notification on notification page
    kDatabase
        .child('notification')
        .child(profileId)
        .child(_currentUser!.userId!)
        .set({
      'type': NotificationType.Follow.toString(),
      'createdAt': DateTime.now().toUtc().toString(),
      'data': UserModel(
              displayName: _currentUser!.displayName,
              profilePic: _currentUser!.profilePic,
              isVerified: _currentUser!.isVerified,
              userId: _currentUser!.userId,
              bio: _currentUser!.bio == "Edit profile to update bio"
                  ? ""
                  : _currentUser!.bio,
              userName: _currentUser!.userName)
          .toJson()
    });
  }
}
