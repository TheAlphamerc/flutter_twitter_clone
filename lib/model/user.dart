class User {
  String key;
  String email;
  String userId;
  String displayName;
  String userName;
  String webSite;
  String profilePic;
  String contact;
  String bio;
  String location;
  String dob;
  String createdAt;
  bool isVerified;
  int followers = 0;
  int following = 0;

  User({this.email, this.userId, this.displayName, this.profilePic,this.key,this.contact,this.bio,this.dob,this.location,this.createdAt,this.userName,this.followers,this.following,this.webSite,this.isVerified});

   User.fromJson(Map<dynamic, dynamic> map) {
     if(map == null){
       return ;
     }
    email = map['email'];
    userId = map['userId'];
    displayName = map['displayName'];
    profilePic = map['profilePic'];
    key = map['key'];
    dob = map['dob'];
    bio = map['bio'];
    location = map['location'];
    contact = map['contact'];
    createdAt = map['createdAt'];
    followers = map['followers'] ?? 0;
    following = map['following'] ?? 0;
    userName = map['userName'];
    webSite = map['webSite'];
    isVerified = map['isVerified'] ?? false;
  }
  toJson() {
    return {
      'key':key,
      "userId": userId,
      "email": email,
      'displayName': displayName,
      'userId': userId,
      'profilePic': profilePic,
      'contact':contact,
      'dob':dob,
      'bio':bio,
      'location':location,
      'createdAt':createdAt,
      'followers':followers ?? 0,
      'following':following ?? 0,
      'userName':userName,
      'webSite':webSite,
      'isVerified':isVerified ?? false
    };
  }
}