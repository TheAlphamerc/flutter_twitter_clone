import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_twitter_clone/helper/shared_prefrence_helper.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/bookmarkModel.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/ui/page/common/locator.dart';
import 'appState.dart';

class BookmarkState extends AppState {
  BookmarkState() {
    getDataFromDatabase();
  }
  List<FeedModel>? _tweetList;
  List<BookmarkModel>? _bookmarkList;

  addBookmarkTweetToList(BookmarkModel model) {
    _bookmarkList ??= <BookmarkModel>[];

    if (!_bookmarkList!.any((element) => element.key == model.key)) {
      _bookmarkList!.add(model);
    }
  }

  List<FeedModel>? get tweetList => _tweetList;

  /// get [Notification list] from firebase realtime database
  void getDataFromDatabase() async {
    String userId = await getIt<SharedPreferenceHelper>()
        .getUserProfile()
        .then((value) => value!.userId!);
    try {
      if (_tweetList != null) {
        return;
      }
      isBusy = true;
      kDatabase
          .child('bookmark')
          .child(userId)
          .once()
          .then((DatabaseEvent event) async {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;
          if (map != null) {
            map.forEach((bookmarkKey, value) {
              var map = value as Map<dynamic, dynamic>;
              var model = BookmarkModel.fromJson(map);
              model.key = bookmarkKey;
              addBookmarkTweetToList(model);
            });
          }

          if (_bookmarkList != null) {
            for (var bookmark in _bookmarkList!) {
              var tweet = await getTweetDetail(bookmark.tweetId);
              if (tweet != null) {
                _tweetList ??= <FeedModel>[];
                _tweetList!.add(tweet);
              }
            }
          }
        }
        isBusy = false;
      });
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get `Tweet` present in notification
  Future<FeedModel?> getTweetDetail(String tweetId) async {
    FeedModel _tweetDetail;
    final event = await kDatabase.child('tweet').child(tweetId).once();

    final snapshot = event.snapshot;
    if (snapshot.value != null) {
      var map = snapshot.value as Map<dynamic, dynamic>;
      _tweetDetail = FeedModel.fromJson(map);
      _tweetDetail.key = snapshot.key!;
      return _tweetDetail;
    } else {
      return null;
    }
  }
}
