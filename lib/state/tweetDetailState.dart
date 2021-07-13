import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:flutter_twitter_clone/state/base/tweetBaseState.dart';

class TweetDetailState extends TweetBaseState {
  String postId;
  FeedModel tweet;
  final bool isLoadComents;

  TweetDetailState(
      {String postId, FeedModel tweet, this.isLoadComents = true}) {
    assert(this.postId == null || tweet == null,
        "PostId and Tweet both can not be null\nOne of them should have value");
    this.tweet = tweet;
    this.postId = postId ?? tweet?.key;
    getTweet(this.postId);
    initTweetDetail();
  }
  List<FeedModel> commentlist;
  dabase.Query _feedQuery;
  StreamSubscription<Event> tweetSubscription;

  void initTweetDetail() async {
    try {
      if (_feedQuery == null) {
        _feedQuery = kDatabase.child("tweet").child(postId);
        tweetSubscription = _feedQuery.onValue.listen(_onTweetChanged);
      }
    } catch (error, stacktrace) {
      cprint(error, errorIn: 'databaseInit', stacktrace: stacktrace);
      return Future.value(false);
    }
  }

  /// get [Tweet Detail] from firebase realtime kDatabase
  /// If model is null then fetch tweet from firebase
  /// [getpostDetailFromDatabase] is used to set prepare Tweetr to display Tweet detail
  /// After getting tweet detail fetch tweet coments from firebase
  void getTweet(String postID, {FeedModel model}) async {
    try {
      loading = true;
      if (model != null) {
        // set tweet data from tweet list data.
        // No need to fetch tweet from firebase db if data already present in tweet list
        tweet = model;
        postID = model.key;
      } else {
        // Fetch tweet data from firebase
        tweet = await getpostDetailFromDatabase(postID);
      }
      if (isLoadComents) {
        commentlist = await getTweetsComments(tweet);
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'getpostDetailFromDatabase');
    }
    loading = false;
  }

  /// Add [new comment tweet] to any tweet
  /// Comment is a Tweet itself
  addcomment(FeedModel commentTweet) {
    try {
      var json = commentTweet.toJson();
      createPost(commentTweet);
      kDatabase.child('tweet').push().set(json).then((value) {
        // tweet.replyTweetKeyList.add(_feedlist.last.key);
        // updateTweet(tweet);
      });
    } catch (error) {
      cprint(error, errorIn: 'addcommentToPost');
    }

    notifyListeners();
  }

  /// Add/Remove like on a Tweet
  handleTweetLike(FeedModel model, String userId) {
    addLikeToTweet(model, userId);
    notifyListeners();
  }

  void _onTweetChanged(Event event) async {
    var newModel = FeedModel.fromJson(event.snapshot.value);
    if (newModel.replyTweetKeyList != tweet.replyTweetKeyList) {
      if (isLoadComents) {
        commentlist = await getTweetsComments(tweet);
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _feedQuery = null;
    tweetSubscription.cancel();
    super.dispose();
  }
}
