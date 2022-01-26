import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/appState.dart';

class SuggestionsState extends AppState {
  List<UserModel>? _userlist;

  UserModel? currentUser;
  void initUser(UserModel? model) {
    if (model != null && currentUser != model) {
      currentUser = model;
      _displaySuggestions = int.tryParse(currentUser!.getFollowing)! < 5;
    }
  }

  bool _displaySuggestions = false;
  bool get displaySuggestions => _displaySuggestions;
  set displaySuggestions(bool value) {
    if (value != _displaySuggestions) {
      _displaySuggestions = value;
      notifyListeners();
    }
  }

  List<UserModel>? get userlist => _userlist;
  void setUserlist(List<UserModel>? list) {
    if (list != null && _userlist == null) {
      list.sort((a, b) {
        if (a.followersList != null && b.followersList != null) {
          return b.followersList!.length.compareTo(a.followersList!.length);
        } else if (a.followersList != null) {
          return 0;
        }
        return 1;
      });

      _userlist = list.take(20).toList();
      _userlist!.removeWhere((element) => isFollowing(element));
      _selectedusers = List.from(_userlist!);
    }
  }

  /// Check if user followerlist contain your or not
  /// If your id exist in follower list it mean you are following him
  bool isFollowing(UserModel user) {
    if (user.followersList != null &&
        user.followersList!.any((x) => x == currentUser!.userId)) {
      return true;
    } else {
      return false;
    }
  }

  List<UserModel> _selectedusers = [];
  int get selectedusersCount => _selectedusers.length;

  bool isSelected(UserModel user) {
    return _selectedusers.contains(user);
  }

  void toggleAllSelections() {
    if (_selectedusers.length == _userlist!.length) {
      _selectedusers = [];
    } else {
      _selectedusers = List.from(_userlist!);
    }
    notifyListeners();
  }

  void toggleUserSelection(UserModel user) {
    if (isSelected(user)) {
      _selectedusers.remove(user);
    } else {
      _selectedusers.add(user);
    }

    notifyListeners();
  }

  /// get [UserModel list] from firebase realtime Database
  void getDataFromDatabase() {
    try {} catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  Future<void> followUsers() async {
    try {
      if (_selectedusers.length > 0) {
        /// Add current user id to the following list of all selected users
        for (final user in _selectedusers) {
          user.followersList ??= [];
          user.followersList!.add(currentUser!.userId!);
          user.followers = user.followersList!.length;
          await kDatabase
              .child('profile')
              .child(user.userId!)
              .child('followerList')
              .set(user.followersList);

          cprint('user added to following list');
        }

        /// Add all selected users to current user following list
        currentUser!.followingList ??= [];
        currentUser!.followingList!
            .addAll(_selectedusers.map((e) => e.userId!));
        currentUser!.following = currentUser!.followingList!.length;
        await kDatabase
            .child('profile')
            .child(currentUser!.userId!)
            .child('followingList')
            .set(currentUser!.followingList);

        // await getIt<SharedPreferenceHelper>().saveUserProfile(currentUser!);

        displaySuggestions = false;
      }
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'followUsers');
    }
  }
}
