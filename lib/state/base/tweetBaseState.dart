import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/appState.dart';

class TweetBaseState extends AppState {
  /// get [Tweet Detail] from firebase realtime kDatabase
  /// If model is null then fetch tweet from firebase
  /// [getpostDetailFromDatabase] is used to set prepare Tweetr to display Tweet detail
  /// After getting tweet detail fetch tweet coments from firebase
  Future<FeedModel?> getpostDetailFromDatabase(String postID) async {
    try {
      late FeedModel tweet;

      // Fetch tweet data from firebase
      return await kDatabase
          .child('tweet')
          .child(postID)
          .once()
          .then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var map = snapshot.value as Map;
          tweet = FeedModel.fromJson(map);
          tweet.key = snapshot.key!;
        }
        return tweet;
      });
    } catch (error) {
      cprint(error, errorIn: 'getpostDetailFromDatabase');
      return null;
    }
  }

  Future<List<FeedModel>?> getTweetsComments(FeedModel post) async {
    late List<FeedModel> _commentlist;
    // Check if parent tweet has reply tweets or not
    if (post.replyTweetKeyList != null && post.replyTweetKeyList!.isNotEmpty) {
      // for (String? x in post.replyTweetKeyList!) {
      //   if (x == null) {
      //     return;
      //   }
      // }
      //FIXME
      _commentlist = [];
      for (String? replyTweetId in post.replyTweetKeyList!) {
        if (replyTweetId != null) {
          await kDatabase
              .child('tweet')
              .child(replyTweetId)
              .once()
              .then((DatabaseEvent event) {
            final snapshot = event.snapshot;
            if (snapshot.value != null) {
              var commentmodel = FeedModel.fromJson(snapshot.value as Map);
              var key = snapshot.key!;
              commentmodel.key = key;

              /// add comment tweet to list if tweet is not present in [comment tweet ]list
              /// To reduce duplicacy
              if (!_commentlist.any((x) => x.key == key)) {
                _commentlist.add(commentmodel);
              }
            } else {}
            if (replyTweetId == post.replyTweetKeyList!.last) {
              /// Sort comment by time
              /// It helps to display newest Tweet first.
              _commentlist.sort((x, y) => DateTime.parse(y.createdAt)
                  .compareTo(DateTime.parse(x.createdAt)));
            }
          });
        }
      }
    }
    return _commentlist;
  }

  /// [Delete tweet] in Firebase kDatabase
  /// Remove Tweet if present in home page Tweet list
  /// Remove Tweet if present in Tweet detail page or in comment
  bool deleteTweet(
    String tweetId,
    TweetType type,
    /*{String parentkey}*/
  ) {
    try {
      /// Delete tweet if it is in nested tweet detail page
      kDatabase.child('tweet').child(tweetId).remove();
      return true;
    } catch (error) {
      cprint(error, errorIn: 'deleteTweet');
      return false;
    }
  }

  /// [update] tweet
  void updateTweet(FeedModel model) async {
    await kDatabase.child('tweet').child(model.key!).set(model.toJson());
  }

  /// Add/Remove like on a Tweet
  /// [postId] is tweet id, [userId] is user's id who like/unlike Tweet
  void addLikeToTweet(FeedModel tweet, String userId) {
    try {
      if (tweet.likeList != null &&
          tweet.likeList!.isNotEmpty &&
          tweet.likeList!.any((id) => id == userId)) {
        // If user wants to undo/remove his like on tweet
        tweet.likeList!.removeWhere((id) => id == userId);
        tweet.likeCount = tweet.likeCount! - 1;
      } else {
        // If user like Tweet
        tweet.likeList ??= [];
        tweet.likeList!.add(userId);
        tweet.likeCount = tweet.likeCount! + 1;
      }
      // update likelist of a tweet
      kDatabase
          .child('tweet')
          .child(tweet.key!)
          .child('likeList')
          .set(tweet.likeList);

      // Sends notification to user who created tweet
      // UserModel owner can see notification on notification page
      kDatabase
          .child('notification')
          .child(tweet.userId)
          .child(tweet.key!)
          .set({
        'type':
            tweet.likeList!.isEmpty ? null : NotificationType.Like.toString(),
        'updatedAt':
            tweet.likeList!.isEmpty ? null : DateTime.now().toUtc().toString(),
      });
    } catch (error) {
      cprint(error, errorIn: 'addLikeToTweet');
    }
  }

  /// Add new [tweet]
  /// Returns new tweet id
  String? createPost(FeedModel tweet) {
    var json = tweet.toJson();
    var refence = kDatabase.child('tweet').push();
    refence.set(json);
    return refence.key;
  }

  /// upload [file] to firebase storage and return its  path url
  Future<String?> uploadFile(File file) async {
    try {
      // isBusy = true;
      notifyListeners();
      var storageReference = FirebaseStorage.instance
          .ref()
          .child("tweetImage")
          .child(Path.basename(DateTime.now().toIso8601String() + file.path));
      await storageReference.putFile(file);

      var url = await storageReference.getDownloadURL();
      return url;
    } catch (error) {
      cprint(error, errorIn: 'uploadFile');
      return null;
    }
  }
}
