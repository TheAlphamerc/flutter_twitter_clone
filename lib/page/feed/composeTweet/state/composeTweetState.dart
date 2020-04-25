import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';

class ComposeTweetState extends ChangeNotifier {
  bool showUserList = false;
  bool enableSubmitButton = false;
  bool hideUserList = false;
  String description = "";
  final usernameRegex = r'(@\w*[a-zA-Z1-9]$)';

  bool _isScrollingDown  = false;
  bool get isScrollingDown  => _isScrollingDown;
  set setIsScrolllingDown(bool value){
    _isScrollingDown = value;
    notifyListeners();
  }

  /// Display/Hide userlist on the basis of username availability in description
  bool get displayUserList {
    RegExp regExp = new RegExp(usernameRegex);
    var status = regExp.hasMatch(description);
    if (status && !hideUserList) {
      return true;
    } else {
      return false;
    }
  }

  /// Hide userlist when a username is selected from userlist
  void onUserSelected() {
    hideUserList = true;
    notifyListeners();
  }

  void onDescriptionChanged(String text, SearchState searchState) {
    description = text;
    hideUserList = false;
    if (text.isEmpty || text.length > 280) {
      /// Disable submit button if description is not availabele
      enableSubmitButton = false;
      notifyListeners();
      return;
    }

    /// Enable submit button if description is availabele
    enableSubmitButton = true;
    var last = text.substring(text.length - 1, text.length);

    /// Regex to search last username from description
    /// Ex. `Hello @john do you know @ricky`
    /// In above description reegex is serch for last username ie. `@ricky`.

    RegExp regExp = new RegExp(usernameRegex);
    var status = regExp.hasMatch(text);
    if (status) {
      Iterable<Match> _matches = regExp.allMatches(text);
      var name = text.substring(_matches.last.start, _matches.last.end);

      /// If last character is `@` then reset search user list
      if (last == "@") {
        /// Reset user list
        searchState.filterByUsername("");
      } else {
        /// Filter user list according to name
        searchState.filterByUsername(name);
      }
    } else {
      /// Hide userlist if no matched username found
      hideUserList = false;
      notifyListeners();
    }
  }

  /// When user select user from userlist it will add username in description
  String getDescription(String username) {
    RegExp regExp = new RegExp(usernameRegex);
    Iterable<Match> _matches = regExp.allMatches(description);
    var name = description.substring(0, _matches.last.start);
    description = '$name $username';
    return description;
  }
}
