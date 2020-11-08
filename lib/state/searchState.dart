import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'appState.dart';

class SearchState extends AppState {
  bool isBusy = false;
  SortUser sortBy = SortUser.ByMaxFollower;
  List<UserModel> _userFilterlist;
  List<UserModel> _userlist;

  List<UserModel> get userlist {
    if (_userFilterlist == null) {
      return null;
    } else {
      return List.from(_userFilterlist);
    }
  }

  /// get [UserModel list] from firebase realtime Database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      kDatabase.child('profile').once().then(
        (DataSnapshot snapshot) {
          _userlist = List<UserModel>();
          _userFilterlist = List<UserModel>();
          if (snapshot.value != null) {
            var map = snapshot.value;
            if (map != null) {
              map.forEach((key, value) {
                var model = UserModel.fromJson(value);
                model.key = key;
                _userlist.add(model);
                _userFilterlist.add(model);
              });
              _userFilterlist
                  .sort((x, y) => y.followers.compareTo(x.followers));
            }
          } else {
            _userlist = null;
          }
          isBusy = false;
        },
      );
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// It will reset filter list
  /// If user has use search filter and change screen and came back to search screen It will reset user list.
  /// This function call when search page open.
  void resetFilterList() {
    if (_userlist != null && _userlist.length != _userFilterlist.length) {
      _userFilterlist = List.from(_userlist);
      _userFilterlist.sort((x, y) => y.followers.compareTo(x.followers));
      notifyListeners();
    }
  }

  /// This function call when search fiels text change.
  /// UserModel list on  search field get filter by `name` string
  void filterByUsername(String name) {
    if (name.isEmpty &&
        _userlist != null &&
        _userlist.length != _userFilterlist.length) {
      _userFilterlist = List.from(_userlist);
    }
    // return if userList is empty or null
    if (_userlist == null && _userlist.isEmpty) {
      print("Empty userList");
      return;
    }
    // sortBy userlist on the basis of username
    else if (name != null) {
      _userFilterlist = _userlist
          .where((x) =>
              x.userName != null &&
              x.userName.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Sort user list on search user page.
  set updateUserSortPrefrence(SortUser val) {
    sortBy = val;
    notifyListeners();
  }

  String get selectedFilter {
    switch (sortBy) {
      case SortUser.ByAlphabetically:
        _userFilterlist.sort((x, y) => x.displayName.compareTo(y.displayName));
        notifyListeners();
        return "alphabetically";

      case SortUser.ByMaxFollower:
        _userFilterlist.sort((x, y) => y.followers.compareTo(x.followers));
        notifyListeners();
        return "UserModel with max follower";

      case SortUser.ByNewest:
        _userFilterlist.sort((x, y) =>
            DateTime.parse(y.createdAt).compareTo(DateTime.parse(x.createdAt)));
        notifyListeners();
        return "Newest user first";

      case SortUser.ByOldest:
        _userFilterlist.sort((x, y) =>
            DateTime.parse(x.createdAt).compareTo(DateTime.parse(y.createdAt)));
        notifyListeners();
        return "Oldest user first";

      case SortUser.ByVerified:
        _userFilterlist.sort((x, y) =>
            y.isVerified.toString().compareTo(x.isVerified.toString()));
        notifyListeners();
        return "Verified user first";

      default:
        return "Unknown";
    }
  }

  /// Return user list relative to provided `userIds`
  /// Method is used on
  List<UserModel> userList = [];
  List<UserModel> getuserDetail(List<String> userIds) {
    final list = _userlist.where((x) {
      if (userIds.contains(x.key)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return list;
  }
}
