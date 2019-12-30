import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/commentModel.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:path/path.dart' as Path;  

import 'authState.dart';

class FeedState extends AuthState {
  final databaseReference = Firestore.instance;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<FeedModel> _feedlist;
  // bool isbbusy = false;
  FeedModel _feedModel;
  List<FeedModel> _commentlist;
  dabase.Query _feedQuery;
  dabase.Query _commentQuery;
  FeedModel get feedModel => _feedModel;
  set setFeedModel(FeedModel model){
    _feedModel = model;
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

  Future<bool> databaseInit() {
    try {
      if (_feedQuery == null) {
        _feedQuery = _database.reference().child("feed");
        _commentQuery = _database.reference().child("comment");
        _feedQuery.onChildAdded.listen(_onTweetAdded);
        _feedQuery.onChildChanged.listen(_onTweetChanged);

        _commentQuery.onChildAdded.listen(_onCommentChanged);
        _commentQuery.onChildChanged.listen(_onCommentAdded);
        
      }

      return Future.value(true);
    } catch (error) {
      cprint(error);
      return Future.value(false);
    }
  }

 void getDataFromDatabase() {
    try {
      isBusy = true;
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference.child('feed').once().then((DataSnapshot snapshot) {
        _feedlist = List<FeedModel>();
        if(snapshot.value != null){
          var map = snapshot.value;
          if(map != null){
             map.forEach((key, value) {
             var  model = FeedModel.fromJson(value);
             model.key = key;
             _feedlist.add(model);
            });
          }
        }
        else{
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
 
 void getpostDetailFromDatabase(String postID) {
    try {
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference.child('feed').child(postID).once().then((DataSnapshot snapshot) {
        if(snapshot.value != null){
          var map = snapshot.value;
          _feedModel = FeedModel.fromJson(map);
          _feedModel.key =  snapshot.key;
          }
        else{
            _feedModel = null;
        }
        
      }).then((value){
      databaseReference.child('comment').child(postID).once().then((DataSnapshot snapshot) {
           snapshot = snapshot;
           _commentlist = List<FeedModel>();
           if(snapshot.value != null){
             var map = snapshot.value;
             map.forEach((key,value){
              var commentmodel = FeedModel.fromJson(value);
               commentmodel.key = key;
                if(_commentlist == null){
                  _commentlist = List<FeedModel>();
                }
                _commentlist.add(commentmodel);
             });
           }
           else{
               _commentlist = null;
           }
           
          notifyListeners();
         });
      });
    } catch (error) {
      cprint(error);
    }
  }
 
 createTweet(FeedModel model) {
    ///  Create feed in [Firebase database]
    try {
        _database
            .reference()
            .child('feed')
            .push()
            .set(model.toJson());
    } catch (error) {
      cprint(error);
    }
  }
  deleteTweet(String tweetId,TweetType type) {
    ///  Delete feed in [Firebase database]
    try {
       if(type == TweetType.Reply){
          _database
            .reference()
            .child('comment')
            .child(_feedModel.key)
            .remove().then((_){
              _commentlist.removeWhere((x)=>x.key == tweetId);
              if(_commentlist.length ==0){
                _commentlist = null;
              }
                _feedModel.commentCount = _commentlist == null ? 0 : _commentlist.length ;
                _database.reference().child('feed').child(_feedModel.key).set(_feedModel.toJson()).then((_){
                  cprint('Reply  deleted');
                  notifyListeners();
                });
            });
            return;
       }
       else{
          _database
            .reference()
            .child('feed')
            .child(tweetId)
            .remove().then((_){
                if(_feedlist.any((x)=>x.key == tweetId)){
                  if(_feedModel.imagePath != null && _feedModel.imagePath.length >0){
                    deleteFile(_feedModel.imagePath,'feeds');
                  }
                  _feedlist.removeWhere((x)=>x.key == tweetId);
                  if(_feedlist.length ==0){
                    _feedlist = null;
                  }
                  notifyListeners();
                  cprint('Tweet deleted');
                }
            });
        _database
            .reference()
            .child('comment')
            .child(tweetId)
            .remove();
       }
    } catch (error) {
      cprint(error);
    }
  }
 
  Future<void> uploadFile(File file,FeedModel model) async {  
   try{
     StorageReference storageReference = FirebaseStorage.instance.ref().child('feeds${Path.basename(file.path)}');    
     StorageUploadTask uploadTask = storageReference.putFile(file);    
     await uploadTask.onComplete.then((value){
          storageReference.getDownloadURL().then((fileURL) {    
              print(fileURL);
              model.imagePath = fileURL;
              createTweet(model);
         });
      }); 
   } catch(error){
     cprint(error);
   }   
 } 
 Future<void> deleteFile(String url,String baseUrl)async{
    try{
       String filePath = url.replaceAll(new RegExp(r'https://firebasestorage.googleapis.com/v0/b/twitter-clone-4fce9.appspot.com/o/'), '');
       filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');
       filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');
      //  filePath = filePath.replaceAll('feeds/', '');
    //  cprint('[Path]'+filePath);
     StorageReference storageReference = FirebaseStorage.instance.ref();    
     await storageReference.child(filePath).delete().catchError((val){
        cprint('[Error]'+val);
     }) .then((_){
       cprint('[Sucess] Image deleted');
     });
     
   } catch(error){
     cprint(error);
   } 
 } 
  addLikeToComment({String postId,FeedModel commentModel,String userId}){
     try {
      if (commentModel != null) {
      //  var model = _commentlist.firstWhere((x)=>x.key == commentId);
        if(commentModel.likeList != null && commentModel.likeList.length >0 && commentModel.likeList.any((x)=>x.userId == userId)){
          commentModel.likeList.removeWhere((x)=>x.userId == userId);
          commentModel.likeCount -= 1; 
          _database
            .reference()
            .child('comment')
            .child(postId)
            .child(commentModel.key)
            .set(commentModel.toJson());
        }
        else{
          /// If there is no like available
           _database
            .reference()
            .child('comment')
            .child(postId)
            .child(commentModel.key)
            .child('likeList')
            .child(userId)
            .set({'userId':userId});
        }
       
      }
    } catch (error) {
      cprint(error);
    }
  }
  /// [postId] is tweet id, [userId] is user's id
  addLikeToTweet(String postId,String userId){
     try {
      if (postId != null) {
        if(_commentlist != null && _commentlist.length > 0 && _commentlist.any((x)=>x.key == postId)){
           var model = _commentlist.firstWhere((x)=>x.key == postId);
          addLikeToComment(postId: _feedModel.key,commentModel: model,userId:userId);
          return;
        }
         FeedModel model = _feedlist.firstWhere((x)=>x.key == postId);
        if(model.likeList != null && model.likeList.length >0 && model.likeList.any((x)=>x.userId == userId)){
          model.likeList.removeWhere((x)=>x.userId == userId,);
          model.likeCount -= 1; 
          _database
            .reference()
            .child('feed')
            .child(postId)
            .set(model.toJson());
        }
        else{
           _database
            .reference()
            .child('feed')
            .child(postId)
            .child('likeList')
            .child(userId)
            .set({'userId':userId});
        }
       
      }
    } catch (error) {
      cprint(error);
    }
  }
  addcommentToPost(String postId,{String userId,String comment,User user,List<String> tags}){
    if(comment == null || comment.isEmpty){
      return;
    }
     try {
      if (postId != null) {
        FeedModel tweet = _feedlist.firstWhere((x)=>x.key == postId);
        FeedModel reply = FeedModel(description: comment,user:user,createdAt: DateTime.now().toString(),tags:tags,userId: user.userId );
        var json = reply.toJson();
        _database
            .reference()
            .child('comment')
            .child(postId)
            .push()
            .set(json).then((value){
               FeedModel model = _feedlist.firstWhere((x)=>x.key == postId);
               model.commentCount += 1;
               _database.reference().child('feed').child(postId).set(tweet.toJson());
            });
            // child(postId)
      }
    } catch (error) {
      cprint(error);
    }
  }
  
  _onTweetChanged(Event event) {
    var oldEntry = _feedlist.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    FeedModel _feed  = FeedModel.fromJson(event.snapshot.value);
    _feed.key = event.snapshot.key;
      _feedlist[_feedlist.indexOf(oldEntry)] = _feed;
      if(_feedModel != null && _feedModel.key == _feed.key){
         _feedModel = _feed;
      }
    if (event.snapshot != null) {
      cprint('feed updated');
      notifyListeners();
    }
  }

  _onTweetAdded(Event event) {
     FeedModel _feed  = FeedModel.fromJson(event.snapshot.value);
    _feed.key = event.snapshot.key;
    if (_feedlist == null) {
      _feedlist = List<FeedModel>();
    }
    if( _feedlist.length == 0 || _feedlist.any((x)=>x.key != _feed.key)){
       _feedlist.add(_feed);
    }
    if (event.snapshot != null) {
      cprint('feed created');
    }
    notifyListeners();
  }

  _onCommentChanged(Event event) {
    FeedModel _comment;
     if (_commentlist == null) {
      _commentlist = List<FeedModel>();
    }
     event.snapshot.value.forEach((key,value){
      _comment = FeedModel.fromJson(value);
      _comment.key = key;
       _commentlist.add(_comment);
    });
        
    if (event.snapshot != null) {
      cprint('feed updated');
      notifyListeners();
    }
  }

  _onCommentAdded(Event event) {
    FeedModel _comment;
     if (_commentlist == null) {
      _commentlist = List<FeedModel>();
    }
       _commentlist.clear();
    event.snapshot.value.forEach((key,value){
      _comment = FeedModel.fromJson(value);
      _comment.key = key;
        _commentlist.add(_comment);
    });
    _feedModel.commentCount = _commentlist.length;
    if (event.snapshot != null) {
      cprint('Comment created');
    }
    notifyListeners();
  }

}
