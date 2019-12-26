import 'package:flutter/material.dart';

class AppState extends ChangeNotifier{
  bool isBusy = true;
  // get isbusy => _isBusy;
  // set isbusy(bool value){
  //   _isBusy = value;
  // }
  int _pageIndex = 0;
  int get pageIndex {
     return _pageIndex;
  } 
  set setpageIndex(int index){
    _pageIndex = index;
    notifyListeners();
  }
}