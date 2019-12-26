class User {
  String key;
  String email;
  String userId;
  String displayName;
  String userName;
  String webSite;
  String photoUrl;
  String contact;
  String bio;
  String location;
  String dob;
  String createdAt;
  int followers = 0;
  int following = 0;

  User({this.email, this.userId, this.displayName, this.photoUrl,this.key,this.contact,this.bio,this.dob,this.location,this.createdAt,this.userName,this.followers,this.following,this.webSite});

   User.fromJson(Map<dynamic, dynamic> map) {
    email = map['email'];
    userId = map['userId'];
    displayName = map['displayName'];
    photoUrl = map['photoUrl'];
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
  }

  Map<String, dynamic> get getUser {
    return {
      'key':key,
      'email': email,
      'displayName': displayName,
      'userId': userId,
      'photoUrl': photoUrl,
      'contact':contact,
      'dob':dob,
      'bio':bio,
      'location':location,
      'createdAt':createdAt,
      'followers':followers ?? 0,
      'following':following ?? 0,
      'userName':userName,
      'webSite':webSite
    };  
  }
  toJson() {
    return {
      'key':key,
      "userId": userId,
      "email": email,
      'displayName': displayName,
      'userId': userId,
      'photoUrl': photoUrl,
      'contact':contact,
      'dob':dob,
      'bio':bio,
      'location':location,
      'createdAt':createdAt,
      'followers':followers ?? 0,
      'following':following ?? 0,
      'userName':userName,
      'webSite':webSite
    };
  }
}