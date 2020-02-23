import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:path/path.dart' as Path;
import 'authState.dart';

class FeedState extends AuthState {
  final databaseReference = Firestore.instance;
  bool isBusy = false;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<FeedModel> _feedlist;
  // bool isbbusy = false;
  List<FeedModel> _tweetDetailModel;
  List<FeedModel> _commentlist;
  Map<String, List<FeedModel>> tweetReplyMap = {};
  dabase.Query _feedQuery;
  dabase.Query _commentQuery;
  List<FeedModel> get tweetDetailModel => _tweetDetailModel;
  set setFeedModel(FeedModel model) {
    if (_tweetDetailModel == null) {
      _tweetDetailModel = [];
    }

    /// [Skip if any duplicate tweet already present]
    if (_tweetDetailModel.length == 0 ||
        _tweetDetailModel.length > 0 &&
        !_tweetDetailModel.any((x) => x.key == model.key)) {
         _tweetDetailModel.add(model);
         notifyListeners();
       }
  }

  void removeLastTweetDetail(String tweetKey) {
    if (_tweetDetailModel != null && _tweetDetailModel.length > 0) {
      _tweetDetailModel.removeWhere((x) => x.key == tweetKey);
      tweetReplyMap.removeWhere((key, value) => key == tweetKey);
    }
  }

  List<FeedModel> get feedlist {
    if (_feedlist == null) {
      return null;
    } else {
      return List.from(_feedlist);
    }
  }

  List<FeedModel> get commentlist {
    if (_commentlist == null) {
      return null;
    } else {
      return List.from(_commentlist);
    }
  }
  /// [Intitilise firebase Database]
  Future<bool> databaseInit() {
    try {
      if (_feedQuery == null) {
        _feedQuery = _database.reference().child("feed");
        _commentQuery = _database.reference().child("comment");
        _feedQuery.onChildAdded.listen(_onTweetAdded);
        _feedQuery.onChildChanged.listen(_onTweetChanged);
        // _commentQuery.onChildAdded.listen(_onCommentChanged);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error);
      return Future.value(false);
    }
  }
 /// get [Tweet list] from firebase realtime database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference.child('feed').once().then((DataSnapshot snapshot) {
        _feedlist = List<FeedModel>();
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            map.forEach((key, value) {
              var model = FeedModel.fromJson(value);
              model.key = key;
              _feedlist.add(model);
            });
          }
        } else {
          _feedlist = null;
        }
        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
      cprint(error);
    }
  }
  /// get [Tweet Detail] from firebase realtime database
  void getpostDetailFromDatabase(String postID) {
    try {
      FeedModel _tweetDetail;
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference
          .child('feed')
          .child(postID)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var map = snapshot.value;
          _tweetDetail = FeedModel.fromJson(map);
          _tweetDetail.key = snapshot.key;
          setFeedModel = _tweetDetail;
        } else {
          // _tweetDetailModel = null;
        }
      }).then((value) {
          _commentlist = List<FeedModel>();
        if (_tweetDetail.replyTweetKeyList != null &&
            _tweetDetail.replyTweetKeyList.length > 0) {
          _tweetDetail.replyTweetKeyList.forEach((x) {
            if (x == null) {
              return;
            }
            databaseReference
                .child('feed')
                .child(x)
                .once()
                .then((DataSnapshot snapshot) {
              if (snapshot.value != null) {
                var commentmodel = FeedModel.fromJson(snapshot.value);
                var key = snapshot.key;
                commentmodel.key = key;

                /// add comment tweet to list if [tweet is not present in list]
                if (!_commentlist.any((x) => x.key == key)) {
                  _commentlist.add(commentmodel);
                }
              } else {

              }
              if (x == _tweetDetail.replyTweetKeyList.last) {
                tweetReplyMap.putIfAbsent(postID, () => _commentlist);
                notifyListeners();
              }
            });
          });
        }
        else{
          tweetReplyMap.putIfAbsent(postID, () => _commentlist);
                notifyListeners();
        }
      });
    } catch (error) {
      cprint(error);
    }
  }
  /// create [New Tweet]
  createTweet(FeedModel model) {
    ///  Create feed in [Firebase database]
    isBusy = true;
    notifyListeners();
    try {
      _database.reference().child('feed').push().set(model.toJson());
    } catch (error) {
      cprint(error);
    }
    isBusy = false;
    notifyListeners();
  }
  /// [Delete tweet]
  deleteTweet(String tweetId, TweetType type) {
    ///  Delete feed in [Firebase database]
    try {
        _database.reference().child('feed').child(tweetId).remove().then((_) {
          if (_feedlist.any((x) => x.key == tweetId)) {
            if (_tweetDetailModel.last.imagePath != null &&
                _tweetDetailModel.last.imagePath.length > 0) {
              deleteFile(_tweetDetailModel.last.imagePath, 'feeds');
            }
            _feedlist.removeWhere((x) => x.key == tweetId);
            if (_feedlist.length == 0) {
              _feedlist = null;
            }
            notifyListeners();
            cprint('Tweet deleted');
          }
        });
        _database.reference().child('comment').child(tweetId).remove();
      
    } catch (error) {
      cprint(error);
    }
  }
  /// upload [file] to firebase storage and return its  path url
  Future<String> uploadFile(File file) async {
    try {
      isBusy = true;
      notifyListeners();
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('feeds${Path.basename(file.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(file);
      var snapshot = await uploadTask.onComplete;
      if (snapshot != null) {
        var url = await storageReference.getDownloadURL();
        if (url != null) {
          return url;
        }
      }
    } catch (error) {
      cprint(error);
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
      //  filePath = filePath.replaceAll('feeds/', '');
      //  cprint('[Path]'+filePath);
      StorageReference storageReference = FirebaseStorage.instance.ref();
      await storageReference.child(filePath).delete().catchError((val) {
        cprint('[Error]' + val);
      }).then((_) {
        cprint('[Sucess] Image deleted');
      });
    } catch (error) {
      cprint(error);
    }
  }
  /// add [Like] to tweet
  addLikeToComment({String postId, FeedModel commentModel, String userId}) {
    try {
      if (commentModel != null) {
        //  var model = _commentlist.firstWhere((x)=>x.key == commentId);
        if (commentModel.likeList != null &&
            commentModel.likeList.length > 0 &&
            commentModel.likeList.any((x) => x.userId == userId)) {
          commentModel.likeList.removeWhere((x) => x.userId == userId);
          commentModel.likeCount -= 1;
          _database
              .reference()
              .child('comment')
              .child(postId)
              .child(commentModel.key)
              .set(commentModel.toJson());
        } else {
          /// If there is no like available
          _database
              .reference()
              .child('comment')
              .child(postId)
              .child(commentModel.key)
              .child('likeList')
              .child(userId)
              .set({'userId': userId});
        }
      }
    } catch (error) {
      cprint(error);
    }
  }
  /// [postId] is tweet id, [userId] is user's id
  addLikeToTweet(FeedModel tweet, String userId) {
    try {
      //  FeedModel model = _feedlist.firstWhere((x) => x.key == postId);
      if (tweet.likeList != null &&
          tweet.likeList.length > 0 &&
          tweet.likeList.any((x) => x.userId == userId)) {
        tweet.likeList.removeWhere(
          (x) => x.userId == userId,
        );
        tweet.likeCount -= 1;
        _database
            .reference()
            .child('feed')
            .child(tweet.key)
            .set(tweet.toJson());
      } else {
        _database
            .reference()
            .child('feed')
            .child(tweet.key)
            .child('likeList')
            .child(userId)
            .set({'userId': userId});
      }
    } catch (error) {
      cprint("[addLikeToTweet] $error");
    }
  }
  /// add [new comment tweet] to any tweet
  addcommentToPost(String postId, FeedModel replyTweet) {
    try {
      isBusy = true;
      notifyListeners();
      if (postId != null) {
        FeedModel tweet = _feedlist.firstWhere((x) => x.key == postId);
        
        var json = replyTweet.toJson();
        _database.reference().child('feed').push().set(json).then((value) {
        
          tweet.replyTweetKeyList.add(_feedlist.last.key);
          _database.reference().child('feed').child(postId).set(tweet.toJson());
        });
      }
    } catch (error) {
      cprint(error);
    }
    isBusy = false;
    notifyListeners();
  }

  _onTweetChanged(Event event) {
    var model = FeedModel.fromJson(event.snapshot.value);
    model.key = event.snapshot.key;
    if (_feedlist.any((x) => x.key == model.key)) {
      var oldEntry = _feedlist.singleWhere((entry) {
        return entry.key == event.snapshot.key;
      });
      _feedlist[_feedlist.indexOf(oldEntry)] = model;
    }

    if (_tweetDetailModel != null && _tweetDetailModel.length > 0) {
      if (_tweetDetailModel.any((x) => x.key == model.key)) {

        var oldEntry = _tweetDetailModel.singleWhere((entry) {
           return entry.key == event.snapshot.key;
        });
        _tweetDetailModel[_tweetDetailModel.indexOf(oldEntry)] = model;
      }
      if(tweetReplyMap != null && tweetReplyMap.length > 0){
          if(true){
            var list = tweetReplyMap[model.parentkey];
            //  var list = tweetReplyMap.values.firstWhere((x) => x.any((y) => y.key == model.key));
            if(list != null && list.length > 0){
              list.firstWhere((x) => x.key == model.key).likeCount = model.likeCount;
              list.firstWhere((x) => x.key == model.key).likeList = model.likeList;
            }
            else{
              list = [];
              list.add(model);
            }
          }
      }
    }
    if (event.snapshot != null) {
      cprint('feed updated');
      isBusy = false;
      notifyListeners();
    }
  }

  _onTweetAdded(Event event) {
    FeedModel tweet = FeedModel.fromJson(event.snapshot.value);
    tweet.key = event.snapshot.key;
    _onCommentAdded(tweet);
    tweet.key = event.snapshot.key;
    if (_feedlist == null) {
      _feedlist = List<FeedModel>();
    }
    if (_feedlist.length == 0 || _feedlist.any((x) => x.key != tweet.key)) {
      _feedlist.add(tweet);
    }
    cprint('feed created');
    isBusy = false;
    notifyListeners();
  }

  _onCommentAdded(FeedModel tweet) {
    /// add [new tweet] comment to comment list 
    if(tweetReplyMap != null && tweetReplyMap.length > 0){
       var list = tweetReplyMap[tweet.parentkey];
       if(list != null){
          list.add(tweet);
       }
    }
      cprint('Comment created');
    isBusy = false;
    notifyListeners();
  }

}
