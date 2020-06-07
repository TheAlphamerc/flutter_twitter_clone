import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:path/path.dart' as Path;

import '../helper/constant.dart';
// import 'authState.dart';

class FeedState extends AppState {
  bool isBusy = false;
  Map<String, List<FeedModel>> tweetReplyMap = {};
  FeedModel _tweetToReplyModel;
  FeedModel get tweetToReplyModel => _tweetToReplyModel;
  set setTweetToReply(FeedModel model) {
    _tweetToReplyModel = model;
  }

  List<FeedModel> _commentlist;

  List<FeedModel> _feedlist;
  // dabase.Query _feedQuery;
  List<FeedModel> _tweetDetailModelList;
  List<String> _userfollowingList;
  List<String> get followingList => _userfollowingList;

  List<FeedModel> get tweetDetailModel => _tweetDetailModelList;

  static final CollectionReference _tweetCollection =
      kfirestore.collection(TWEET_COLLECTION);

  /// `feedlist` always [contain all tweets] fetched from firebase database
  List<FeedModel> get feedlist {
    if (_feedlist == null) {
      return null;
    } else {
      return List.from(_feedlist.reversed);
    }
  }

  /// contain tweet list for home page
  List<FeedModel> getTweetList(User userModel) {
    if (userModel == null) {
      return null;
    }

    List<FeedModel> list;

    if (!isBusy && feedlist != null && feedlist.isNotEmpty) {
      list = feedlist.where((x) {
        /// If Tweet is a comment then no need to add it in tweet list
        if (x.parentkey != null &&
            x.childRetwetkey == null &&
            x.user.userId != userModel.userId) {
          return false;
        }

        /// Only include Tweets of logged-in user's and his following user's
        if (x.user.userId == userModel.userId ||
            (userModel?.followingList != null &&
                userModel.followingList.contains(x.user.userId))) {
          return true;
        } else {
          return false;
        }
      }).toList();
      if (list.isEmpty) {
        list = null;
      }
    }
    return list;
  }

  /// set tweet for detail tweet page
  /// Setter call when tweet is tapped to view detail
  /// Add Tweet detail is added in _tweetDetailModelList
  /// It makes `Fwitter` to view nested Tweets
  set setFeedModel(FeedModel model) {
    if (_tweetDetailModelList == null) {
      _tweetDetailModelList = [];
    }

    /// [Skip if any duplicate tweet already present]
    if (_tweetDetailModelList.length >= 0) {
      _tweetDetailModelList.add(model);
      cprint(
          "Detail Tweet added. Total Tweet: ${_tweetDetailModelList.length}");
      // notifyListeners();
    }
  }

  /// `remove` last Tweet from tweet detail page stack
  /// Function called when navigating back from a Tweet detail
  /// `_tweetDetailModelList` is map which contain lists of commment Tweet list
  /// After removing Tweet from Tweet detail Page stack its commnets tweet is also removed from `_tweetDetailModelList`
  void removeLastTweetDetail(String tweetKey) {
    if (_tweetDetailModelList != null && _tweetDetailModelList.length > 0) {
      // var index = _tweetDetailModelList.in
      FeedModel removeTweet =
          _tweetDetailModelList.lastWhere((x) => x.key == tweetKey);
      _tweetDetailModelList.remove(removeTweet);
      tweetReplyMap.removeWhere((key, value) => key == tweetKey);
      cprint(
          "Last Tweet removed from stack. Remaining Tweet: ${_tweetDetailModelList.length}");
      if (_tweetDetailModelList.length > 0) {
        print("Last id available: " + _tweetDetailModelList.last.key);
      }
      notifyListeners();
    }
  }

  /// [clear all tweets] if any tweet present in tweet detail page or comment tweet
  void clearAllDetailAndReplyTweetStack() {
    if (_tweetDetailModelList != null) {
      _tweetDetailModelList.clear();
    }
    if (tweetReplyMap != null) {
      tweetReplyMap.clear();
    }
    cprint('Empty tweets from stack');
  }

  /// [Subscribe Tweets] firebase Database
  Future<bool> databaseInit() {
    try {
      _tweetCollection.snapshots().listen((QuerySnapshot snapshot) {
        // Return if there is no tweets in database
        if (snapshot.documentChanges.isEmpty) {
          return;
        }
        if (snapshot.documentChanges.first.type == DocumentChangeType.added) {
          _onTweetAdded(snapshot.documentChanges.first.document);
        } else if (snapshot.documentChanges.first.type ==
            DocumentChangeType.removed) {
          _onTweetRemoved(snapshot.documentChanges.first.document);
        } else if (snapshot.documentChanges.first.type ==
            DocumentChangeType.modified) {
          _onTweetChanged(snapshot.documentChanges.first.document);
        }
      });

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Tweet list] from firebase realtime database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      _feedlist = null;
      notifyListeners();

      _tweetCollection.getDocuments().then((QuerySnapshot querySnapshot) {
        _feedlist = List<FeedModel>();
        if (querySnapshot != null && querySnapshot.documents.isNotEmpty) {
          for (var i = 0; i < querySnapshot.documents.length; i++) {
            var model = FeedModel.fromJson(querySnapshot.documents[i].data);
            model.key = querySnapshot.documents[i].documentID;
            _feedlist.add(model);
          }

          /// Sort Tweet by time
          /// It helps to display newest Tweet first.
          _feedlist.sort((x, y) => DateTime.parse(x.createdAt)
              .compareTo(DateTime.parse(y.createdAt)));
          notifyListeners();
        } else {
          _feedlist = null;
        }
      });
      isBusy = false;

      // kDatabase.child('tweet').once().then((DataSnapshot snapshot) {
      //   _feedlist = List<FeedModel>();
      //   if (snapshot.value != null) {
      //     var map = snapshot.value;
      //     if (map != null) {
      //       map.forEach((key, value) {
      //         var model = FeedModel.fromJson(value);
      //         model.key = key;
      //         if (model.isValidTweet) {
      //           _feedlist.add(model);
      //         }
      //       });

      //       /// Sort Tweet by time
      //       /// It helps to display newest Tweet first.
      //       _feedlist.sort((x, y) => DateTime.parse(x.createdAt)
      //           .compareTo(DateTime.parse(y.createdAt)));
      //     }
      //   } else {
      //     _feedlist = null;
      //   }
      //   isBusy = false;
      //   notifyListeners();
      // });
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get [Tweet Detail] from firebase realtime kDatabase
  /// If model is null then fetch tweet from firebase
  /// [getpostDetailFromDatabase] is used to set prepare Tweetr to display Tweet detail
  /// After getting tweet detail fetch tweet coments from firebase
  void getpostDetailFromDatabase(String postID, {FeedModel model}) async {
    try {
      FeedModel _tweetDetail;
      if (model != null) {
        // set tweet data from tweet list data.
        // No need to fetch tweet from firebase db if data already present in tweet list
        _tweetDetail = model;
        setFeedModel = _tweetDetail;
        postID = model.key;
      } else {
        // Fetch tweet data from firebase
        _tweetCollection
            .document(postID)
            .get()
            .then((DocumentSnapshot snapshot) {
          var map = snapshot.data;
          _tweetDetail = FeedModel.fromJson(map);
          _tweetDetail.key = snapshot.documentID;
          setFeedModel = _tweetDetail;
        });
        // kDatabase
        //     .child('tweet')
        //     .child(postID)
        //     .once()
        //     .then((DataSnapshot snapshot) {
        //   if (snapshot.value != null) {
        //     var map = snapshot.value;
        //     _tweetDetail = FeedModel.fromJson(map);
        //     _tweetDetail.key = snapshot.key;
        //     setFeedModel = _tweetDetail;
        //   }
        // });
      }

      if (_tweetDetail != null) {
        // Fetch comment tweets
        _commentlist = List<FeedModel>();
        // Check if parent tweet has reply tweets or not
        if (_tweetDetail.replyTweetKeyList != null &&
            _tweetDetail.replyTweetKeyList.length > 0) {
          _tweetDetail.replyTweetKeyList.forEach((tweetKey) {
            if (tweetKey == null) {
              return;
            }
            _tweetCollection
                .document(tweetKey)
                .get()
                .then((DocumentSnapshot snapshot) {
              if (snapshot.data != null) {
                var map = snapshot.data;
                final commentmodel = FeedModel.fromJson(map);
                commentmodel.key = snapshot.documentID;
                commentmodel.key = snapshot.documentID;
                // setFeedModel = _tweetDetail;

                /// add comment tweet to list if tweet is not present in [comment tweet ]list
                /// To reduce duplicacy
                if (!_commentlist.any((x) => x.key == commentmodel.key)) {
                  _commentlist.add(commentmodel);
                }
              }
              if (tweetKey == _tweetDetail.replyTweetKeyList.last) {
                /// Sort comment by time
                /// It helps to display newest Tweet first.
                _commentlist.sort((x, y) => DateTime.parse(y.createdAt)
                    .compareTo(DateTime.parse(x.createdAt)));
                tweetReplyMap.putIfAbsent(postID, () => _commentlist);
              }
            }).whenComplete(() {
              if (tweetKey == _tweetDetail.replyTweetKeyList.last) {
                notifyListeners();
              }
            });

            // kDatabase
            //     .child('tweet')
            //     .child(tweetKey)
            //     .once()
            //     .then((DataSnapshot snapshot) {
            //   if (snapshot.value != null) {
            //     var commentmodel = FeedModel.fromJson(snapshot.value);
            //     var key = snapshot.key;
            //     commentmodel.key = key;

            //     /// add comment tweet to list if tweet is not present in [comment tweet ]list
            //     /// To reduce duplicacy
            //     if (!_commentlist.any((x) => x.key == key)) {
            //       _commentlist.add(commentmodel);
            //     }
            //   } else {}
            //   if (tweetKey == _tweetDetail.replyTweetKeyList.last) {
            //     /// Sort comment by time
            //     /// It helps to display newest Tweet first.
            //     _commentlist.sort((x, y) => DateTime.parse(y.createdAt)
            //         .compareTo(DateTime.parse(x.createdAt)));
            //     tweetReplyMap.putIfAbsent(postID, () => _commentlist);
            //     notifyListeners();
            //   }
            // });
          });
        } else {
          tweetReplyMap.putIfAbsent(postID, () => _commentlist);
          notifyListeners();
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'getpostDetailFromDatabase');
    }
  }

  /// Fetch `Retweet` model from firebase realtime kDatabase.
  /// Retweet itself  is a type of `Tweet`
  Future<FeedModel> fetchTweet(String postID) async {
    FeedModel _tweetDetail;

    /// If tweet is availabe in feedlist then no need to fetch it from firebase
    if (feedlist.any((x) => x.key == postID)) {
      _tweetDetail = feedlist.firstWhere((x) => x.key == postID);
    }

    /// If tweet is not available in feedlist then need to fetch it from firebase
    else {
      cprint("Fetched from DB: " + postID);
      var model = await kDatabase.child('tweet').child(postID).once().then(
        (DataSnapshot snapshot) {
          if (snapshot.value != null) {
            var map = snapshot.value;
            _tweetDetail = FeedModel.fromJson(map);
            _tweetDetail.key = snapshot.key;
            print(_tweetDetail.description);
          }
        },
      );
      if (model != null) {
        _tweetDetail = model;
      } else {
        cprint("Fetched null value from  DB");
      }
    }
    return _tweetDetail;
  }

  /// create [New Tweet]
  Future<void> createTweet(FeedModel model) async {
    ///  Create tweet in [Firebase kDatabase]
    isBusy = true;
    notifyListeners();
    try {
      await _tweetCollection.document().setData(model.toJson());
      // kDatabase.child('tweet').push().set(model.toJson());
    } catch (error) {
      cprint(error, errorIn: 'createTweet');
    }
    isBusy = false;
    notifyListeners();
  }

  ///  It will create tweet in [Firebase kDatabase] just like other normal tweet.
  ///  update retweet count for retweet model
  createReTweet(FeedModel model) {
    try {
      createTweet(model);
      _tweetToReplyModel.retweetCount += 1;
      updateTweet(_tweetToReplyModel);
    } catch (error) {
      cprint(error, errorIn: 'createReTweet');
    }
  }

  /// [Delete tweet] in Firebase kDatabase
  /// Remove Tweet if present in home page Tweet list
  /// Remove Tweet if present in Tweet detail page or in comment
  deleteTweet(String tweetId, TweetType type, {String parentkey}) {
    try {
      /// Delete tweet if it is in nested tweet detail page
      ///  kfirestore

      _tweetCollection.document(tweetId).delete().then((_) {
        if (type == TweetType.Detail &&
            _tweetDetailModelList != null &&
            _tweetDetailModelList.length > 0) {
          // var deletedTweet =
          //     _tweetDetailModelList.firstWhere((x) => x.key == tweetId);
          _tweetDetailModelList.remove(_tweetDetailModelList);
          if (_tweetDetailModelList.length == 0) {
            _tweetDetailModelList = null;
          }

          cprint('Tweet deleted from nested tweet detail page tweet');
        }
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteTweet');
    }
  }

  /// upload [file] to firebase storage and return its  path url
  Future<String> uploadFile(File file) async {
    try {
      isBusy = true;
      notifyListeners();
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('tweetImage${Path.basename(file.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(file);
      var snapshot = await uploadTask.onComplete;
      if (snapshot != null) {
        var url = await storageReference.getDownloadURL();
        if (url != null) {
          return url;
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'uploadFile');
      return null;
    }
  }

  /// [Delete file] from firebase storage
  Future<void> deleteFile(String url, String baseUrl) async {
    try {
      String filePath = url.replaceAll(
          new RegExp(
              r'https://firebasestorage.googleapis.com/v0/b/twitter-clone-4fce9.appspot.com/o/'),
          '');
      filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');
      filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');
      //  filePath = filePath.replaceAll('tweetImage/', '');
      //  cprint('[Path]'+filePath);
      StorageReference storageReference = FirebaseStorage.instance.ref();
      await storageReference.child(filePath).delete().catchError((val) {
        cprint('[Error]' + val);
      }).then((_) {
        cprint('[Sucess] Image deleted');
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteFile');
    }
  }

  /// [update] tweet
  Future<void> updateTweet(FeedModel model) async {
    await _tweetCollection.document(model.key).updateData(model.toJson());
    // await kDatabase.child('tweet').child(model.key).set(model.toJson());
  }

  /// Add/Remove like on a Tweet
  /// [postId] is tweet id, [userId] is user's id who like/unlike Tweet
  addLikeToTweet(FeedModel tweet, String userId) {
    try {
      if (tweet.likeList != null &&
          tweet.likeList.length > 0 &&
          tweet.likeList.any((id) => id == userId)) {
        // If user wants to undo/remove his like on tweet
        tweet.likeList.removeWhere((id) => id == userId);
        tweet.likeCount -= 1;
      } else {
        // If user like Tweet
        if (tweet.likeList == null) {
          tweet.likeList = [];
        }
        tweet.likeList.add(userId);
        tweet.likeCount += 1;
      }
      // update likelist of a tweet
      _tweetCollection.document(tweet.key).updateData(
          {"likeCount": tweet.likeCount, "likeList": tweet.likeList});
      // _tweetCollection
      //     .document(tweet.key)
      //     .collection(TWEET_LIKE_COLLECTION)
      //     .document(TWEET_LIKE_COLLECTION)
      //     .setData({"data": FieldValue.arrayUnion(tweet.likeList)});

      // Sends notification to user who created tweet
      // User owner can see notification on notification page
      if (tweet.likeList.length == 0) {
        kfirestore
            .collection(USERS_COLLECTION)
            .document(tweet.userId)
            .collection(NOTIFICATION_COLLECTION)
            .document(tweet.key)
            .delete();
      } else {
        kfirestore
            .collection(USERS_COLLECTION)
            .document(tweet.userId)
            .collection(NOTIFICATION_COLLECTION)
            .document(tweet.key)
            .setData({
          'type': NotificationType.Like.toString(),
          'updatedAt': DateTime.now().toUtc().toString(),
        });
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'addLikeToTweet');
    }
  }

  /// Add [new comment tweet] to any tweet
  /// Comment is a Tweet itself
  addcommentToPost(FeedModel replyTweet) {
    try {
      isBusy = true;
      notifyListeners();
      if (_tweetToReplyModel != null) {
        FeedModel tweet =
            _feedlist.firstWhere((x) => x.key == _tweetToReplyModel.key);
        createTweet(replyTweet).then((value) {
          tweet.replyTweetKeyList.add(_feedlist.last.key);
          updateTweet(tweet);
        });
      }
    } catch (error) {
      cprint(error, errorIn: 'addcommentToPost');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when any tweet changes or update
  /// When any tweet changes it update it in UI
  /// No matter if Tweet is in home page or in detail page or in comment section.
  _onTweetChanged(DocumentSnapshot event) {
    if (event.data == null) {
      return;
    }
    var model = FeedModel.fromJson(event.data);
    model.key = event.documentID;
    if (_feedlist.any((x) => x.key == model.key)) {
      var oldEntry = _feedlist.lastWhere((entry) {
        return entry.key == event.documentID;
      });
      _feedlist[_feedlist.indexOf(oldEntry)] = model;
    }

    if (_tweetDetailModelList != null && _tweetDetailModelList.length > 0) {
      if (_tweetDetailModelList.any((x) => x.key == model.key)) {
        var oldEntry = _tweetDetailModelList.lastWhere((entry) {
          return entry.key == event.documentID;
        });
        _tweetDetailModelList[_tweetDetailModelList.indexOf(oldEntry)] = model;
      }
      if (tweetReplyMap != null && tweetReplyMap.length > 0) {
        if (true) {
          var list = tweetReplyMap[model.parentkey];
          //  var list = tweetReplyMap.values.firstWhere((x) => x.any((y) => y.key == model.key));
          if (list != null && list.length > 0) {
            var index =
                list.indexOf(list.firstWhere((x) => x.key == model.key));
            list[index] = model;
          } else {
            list = [];
            list.add(model);
          }
        }
      }
    }
    if (event.data != null) {
      cprint('Tweet updated');
      isBusy = false;
      notifyListeners();
    }
  }

  /// Trigger when new tweet added
  /// It will add new Tweet in home page list.
  /// IF Tweet is comment it will be added in comment section too.
  _onTweetAdded(DocumentSnapshot event) {
    FeedModel tweet = FeedModel.fromJson(event.data);
    tweet.key = event.documentID;

    /// Check if Tweet is a comment
    _onCommentAdded(tweet);
    if (_feedlist == null) {
      _feedlist = List<FeedModel>();
    }
    if ((_feedlist.length == 0 || _feedlist.any((x) => x.key != tweet.key)) &&
        tweet.isValidTweet) {
      _feedlist.add(tweet);
      cprint('Tweet Added');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when comment tweet added
  /// Check if Tweet is a comment
  /// If Yes it will add tweet in comment list.
  /// add [new tweet] comment to comment list
  _onCommentAdded(FeedModel tweet) {
    if (tweet.childRetwetkey != null) {
      /// if Tweet is a type of retweet then it can not be a comment.
      return;
    }
    if (tweetReplyMap != null && tweetReplyMap.length > 0) {
      if (tweetReplyMap[tweet.parentkey] != null) {
        tweetReplyMap[tweet.parentkey].add(tweet);
      } else {
        tweetReplyMap[tweet.parentkey] = [tweet];
      }
      cprint('Comment Added');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when Tweet `Deleted`
  /// It removed Tweet from home page list, Tweet detail page list and from comment section if present
  _onTweetRemoved(DocumentSnapshot event) async {
    FeedModel tweet = FeedModel.fromJson(event.data);
    tweet.key = event.documentID;
    var tweetId = tweet.key;
    var parentkey = tweet.parentkey;

    ///  Delete tweet in [Home Page]
    try {
      FeedModel deletedTweet;
      if (_feedlist.any((x) => x.key == tweetId)) {
        /// Delete tweet if it is in home page tweet.
        deletedTweet = _feedlist.firstWhere((x) => x.key == tweetId);
        _feedlist.remove(deletedTweet);

        if (deletedTweet.parentkey != null &&
            _feedlist.isNotEmpty &&
            _feedlist.any((x) => x.key == deletedTweet.parentkey)) {
          // Decrease parent Tweet comment count and update
          var parentModel =
              _feedlist.firstWhere((x) => x.key == deletedTweet.parentkey);
          parentModel.replyTweetKeyList.remove(deletedTweet.key);
          parentModel.commentCount = parentModel.replyTweetKeyList.length;
          updateTweet(parentModel);
        }
        if (_feedlist.length == 0) {
          _feedlist = null;
        }
        cprint('Tweet deleted from home page tweet list');
      }

      /// [Delete tweet] if it is in nested tweet detail comment section page
      if (parentkey != null &&
          parentkey.isNotEmpty &&
          tweetReplyMap != null &&
          tweetReplyMap.length > 0 &&
          tweetReplyMap.keys.any((x) => x == parentkey)) {
        // (type == TweetType.Reply || tweetReplyMap.length > 1) &&
        deletedTweet =
            tweetReplyMap[parentkey].firstWhere((x) => x.key == tweetId);
        tweetReplyMap[parentkey].remove(deletedTweet);
        if (tweetReplyMap[parentkey].length == 0) {
          tweetReplyMap[parentkey] = null;
        }

        if (_tweetDetailModelList != null &&
            _tweetDetailModelList.isNotEmpty &&
            _tweetDetailModelList.any((x) => x.key == parentkey)) {
          var parentModel =
              _tweetDetailModelList.firstWhere((x) => x.key == parentkey);
          parentModel.replyTweetKeyList.remove(deletedTweet.key);
          parentModel.commentCount = parentModel.replyTweetKeyList.length;
          cprint('Parent tweet comment count updated on child tweet removal');
          updateTweet(parentModel);
        }

        cprint('Tweet deleted from nested tweet detail comment section');
      }

      /// Delete tweet image from firebase storage if exist.
      if (deletedTweet.imagePath != null && deletedTweet.imagePath.length > 0) {
        deleteFile(deletedTweet.imagePath, 'tweetImage');
      }

      /// If a retweet is deleted then retweetCount of original tweet should be decrease by 1.
      if (deletedTweet.childRetwetkey != null) {
        await fetchTweet(deletedTweet.childRetwetkey).then((retweetModel) {
          if (retweetModel == null) {
            return;
          }
          if (retweetModel.retweetCount > 0) {
            retweetModel.retweetCount -= 1;
          }
          updateTweet(retweetModel);
        });
      }

      /// Delete notification related to deleted Tweet.
      if (deletedTweet.likeCount > 0) {
        kfirestore
            .collection(USERS_COLLECTION)
            .document(tweet.userId)
            .collection(NOTIFICATION_COLLECTION)
            .document(tweet.key)
            .delete();

        // kDatabase
        //     .child('notification')
        //     .child(tweet.userId)
        //     .child(tweet.key)
        //     .remove();
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onTweetRemoved');
    }
  }
}
