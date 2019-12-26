
class FeedModel {
  String key;
  String description;
  String userId;
  String name;
  String username;
  String profilePic;
  int likeCount;
  List<LikeList> likeList;
  int commentCount;
  String createdAt;
  String imagePath;
  List<String> tags;

  FeedModel({this.key,this.description, this.userId,this.name,this.profilePic,this.likeCount,this.commentCount,this.createdAt,this.imagePath,this.likeList,this.tags,this.username});
  toJson() {
    Map<dynamic,dynamic> map;
    if(likeList != null && likeList.length > 0){
       map = Map.fromIterable(likeList, key: (v) =>v.key, value: (v){  
      var list = LikeList(key: v.key, userId: v.userId);
      return list.toJson();
    });
    }
   
      
    return {
      "userId": userId,
      "description": description,
      "name": name, 
      "profilePic": profilePic,
      "likeCount":likeCount,
      "commentCount":commentCount ?? 0,
      "createdAt":createdAt,
      "imagePath":imagePath,
      "likeList":map,
      "tags":tags,
      "username":username
    };
  }
  dynamic getLikeList(List<String> list){
    if(list != null && list.length > 0){
      // var val = Map.fromIterable(list,)
      // var result = { for (var v in list) v[0]: v[1] };
    var result = Map.fromIterable(list, key: (v) =>'userId', value: (v) => v[0]);
      return result;
    }
  }
  FeedModel.setFeedModel(Map<dynamic, dynamic> map) {
    if(likeList == null){
      likeList = [];
    }
   key = map['key'];
   description = map['description'];
   userId = map['userId'];
   name = map['name'];
   profilePic = map['profilePic'];
   likeCount = map['likeCount'];
   commentCount = map['commentCount'];
   imagePath = map['imagePath'];
   createdAt = map['createdAt'];
   imagePath = map['imagePath'];
   username = map['username'];
   tags = map['tags'];
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
class LikeList{
  String key;
  String userId;
  LikeList({this.key,this.userId});
  LikeList.fromJson(Map<dynamic, dynamic> map,{String key}) {
    key = key;
    userId = map['userId'];
  }
  toJson(){
    return {
      'userId':userId
    };
  }
}