import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'appState.dart';

class SearchState extends AppState {
  final databaseReference = Firestore.instance;
  bool isBusy = false;

  List<User> _userFilterlist;
  List<User> _userlist;

  List<User> get userlist {
    if (_userFilterlist == null) {
      return null;
    } else {
      return List.from(_userFilterlist);
    }
  }

  /// get [User list] from firebase realtime database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference.child('profile').once().then(
        (DataSnapshot snapshot) {
          _userlist = List<User>();
          _userFilterlist = List<User>();
          if (snapshot.value != null) {
            var map = snapshot.value;
            if (map != null) {
              map.forEach((key, value) {
                var model = User.fromJson(value);
                model.key = key;
                _userlist.add(model);
                _userFilterlist.add(model);
              });
            }
          } else {
            _userlist = null;
          }
          isBusy = false;
          notifyListeners();
        },
      );
    } catch (error) {
      isBusy = false;
      cprint(error);
    }
  }

  void filterByUsername(String name) {
    if (name.isEmpty) {
      _userFilterlist = List.from(_userlist);
    }
    // return if userList is empty or null
    if (_userlist == null && _userlist.isEmpty) {
      print("Empty userList");
      return;
    }
    // filter userlist on the basis of username
    else {
      _userFilterlist = _userlist
          .where((x) =>
              x.userName != null &&
              x.userName.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
