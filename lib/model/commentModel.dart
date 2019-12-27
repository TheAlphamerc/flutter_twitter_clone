
import 'feedModel.dart';
import 'user.dart';

class CommentModel {
  String key;
  String description;
  User user;
  int likeCount;
  int commentCount;
  String createdAt;
  String imagePath;
  List<LikeList> likeList;
  CommentModel({this.key,this.description,this.user,this.likeCount,this.createdAt,this.imagePath,this.commentCount,this.likeList});
  toJson() {
     Map<dynamic,dynamic> map;
    if(likeList != null && likeList.length > 0){
       map = Map.fromIterable(likeList, key: (v) =>v.key, value: (v){  
      var list = LikeList(key: v.key, userId: v.userId);
      return list.toJson();
    });
    }
    return {
      "description": description,
      "user": user.toJson(),
      "likeCount":likeCount ?? 0,
      "createdAt":createdAt,
      "imagePath":imagePath,
      "commentCount":commentCount ?? 0,
      "likeList":map,
    };
  }
  CommentModel.fromJson(Map<dynamic, dynamic> map) {
    if(likeList == null){
      likeList = [];
    }
    key = map['key'];
    commentCount = map['commentCount'] ?? 0;
    description = map['description'];
    likeCount = map['likeCount'] ?? 0;
    imagePath = map['imagePath'];
    user = User.fromJson(map['user']);
    createdAt = map['createdAt'];
    if(map['likeList'] != null){
      map['likeList'].forEach((key,value){
       if(value.containsKey('userId')){
         LikeList list = LikeList(key:key,userId: value['userId']);
          likeList.add(list);
       }
     });
     likeCount = likeList.length;
   }
   else{
     likeList = [];
     likeCount = 0;
   }
    
  }
}