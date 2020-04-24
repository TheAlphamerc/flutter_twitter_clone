import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';

class ComposeTweetState extends ChangeNotifier {
  bool showUserList = false;
  bool enableSubmitButton = false;
  bool hideUserList = false;
  String description = "";
  String name = "";
  bool get displayUserList {
    if(description.contains("@") && !hideUserList){
      return true;
    }
    else{
      return false;
    }
  }
  void onUserSelected(){
    hideUserList = true;
     notifyListeners();
  }
  void onDescriptionChanged(String text, SearchState searchState) {
    description = text;
    hideUserList = false;
    if(text.isEmpty || text.length > 280){
      enableSubmitButton = false;
      notifyListeners();
      return;
    }
    var last = text.substring(text.length - 1, text.length);
    final str = r'(@\w*).[^ _!@#$%^&*()+:"<>=[]$';
    RegExp regExp = new RegExp(str);
    var status = regExp.hasMatch(text);
    // Iterable<Match> _matches = regExp.allMatches(text);
    if (status) {
      // print(last);
      Iterable<Match> _matches = regExp.allMatches(text);
      var dd = text.substring(_matches.last.start, _matches.last.end);
      if (last == "@") {
        name = "";
        searchState.filterByUsername("");
      } else {
        // name += last;
        name = dd.substring(1,dd.length);
        searchState.filterByUsername(name);
      }
     enableSubmitButton = true;
     if( dd != null && dd.isNotEmpty){
       notifyListeners();
       print(dd);
     }else{
        hideUserList = false;
        notifyListeners();
        return;
     }
    }
    else{
        hideUserList = false;
        notifyListeners();
     }
  }
}
