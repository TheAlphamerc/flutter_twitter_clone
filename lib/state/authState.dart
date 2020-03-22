import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as Path;
import 'appState.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;

class AuthState extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  bool isSignInWithGoogle = false;
  List<String> profileFollowingList = [];
  FirebaseUser user;
  List<String> userfollowingList = [];
  String userId;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  dabase.Query _profileQuery;
  User _profileUserModel;
  User _userModel;

  User get userModel => _userModel;

  User get profileUserModel => _profileUserModel;

  /// Logout from device
  void logoutCallback() {
    authStatus = AuthStatus.NOT_DETERMINED;
    userId = '';
    _userModel = null;
    _profileUserModel = null;
    userfollowingList = null;
    profileFollowingList = null;
    if (isSignInWithGoogle) {
      _googleSignIn.signOut();
      logEvent('google_logout');
    } else {
      logEvent('email_logout');
      _auth.signOut();
    }
    notifyListeners();
  }

  /// Alter select auth method, login and sign up page
  void openSignUpPage() {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    notifyListeners();
  }

  databaseInit() {
    try {
      if (_profileQuery == null) {
        _profileQuery = _database.reference().child("profile");
        _profileQuery.onChildChanged.listen(_onProfileChanged);
      }
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  /// Verify user's credentials for login
  Future<String> signIn(String email, String password,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      loading = true;
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      userId = user.uid;
      return user.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signIn');
      analytics.logLogin(loginMethod: 'email_login');
      customSnackBar(scaffoldKey, error.message);
      // logoutCallback();
      return null;
    }
  }

  /// Create user from `google login`
  Future<FirebaseUser> handleGoogleSignIn() async {
    try {
      analytics.logLogin(loginMethod: 'google_login');
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if(googleUser == null){
        throw Exception('Google login cancelled by user');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = (await _auth.signInWithCredential(credential)).user;
      authStatus = AuthStatus.LOGGED_IN;
      userId = user.uid;
      isSignInWithGoogle = true;
      createUserFromGoogleSignIn(user);
      notifyListeners();
      return user;
    } catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    }
  }

  /// Create user profile from google login
  createUserFromGoogleSignIn(FirebaseUser user) {
    var diff = DateTime.now().difference(user.metadata.creationTime);
    // Check if user is new or old
    // If user is new then add new user to firebase realtime database
    if (diff < Duration(seconds: 5)) {
      User model = User(
        bio: 'Edit profile to update bio',
        dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
            .toString(),
        location: 'Somewhere in universe',
        profilePic: user.photoUrl,
        displayName: user.displayName,
        email: user.email,
        key: user.uid,
        userId: user.uid,
        contact: user.phoneNumber,
        isVerified: user.isEmailVerified,
      );
      createUser(model, newUser: true);
    } else {
      cprint('Last login at: ${user.metadata.lastSignInTime}');
    }
  }

  /// Create new user's profile in db
  Future<String> signUp(User userModel,
      {GlobalKey<ScaffoldState> scaffoldKey, String password}) async {
    try {
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );
      user = result.user;
      authStatus = AuthStatus.LOGGED_IN;
      analytics.logSignUp(signUpMethod: 'register');
      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = userModel.displayName;
      updateInfo.photoUrl = userModel.profilePic;
      await result.user.updateProfile(updateInfo);
      _userModel = userModel;
      _userModel.key = user.uid;
      _userModel.userId = user.uid;
      createUser(_userModel, newUser: true);
      return user.uid;
    } catch (error) {
      cprint(error, errorIn: 'signUp');
      customSnackBar(scaffoldKey, error.message);
      return null;
    }
  }

  /// `Create` and `Update` user
  /// IF `newUser` is true new user is created
  /// Else existing user will update with new values
  createUser(User user, {bool newUser = false}) {
    if (newUser) {
      // Create username by the combination of name and id
      user.userName = getUserName(id: user.userId, name: user.displayName);
      analytics.logEvent(name: 'create_newUser');

      // Time at which user is created
      user.createdAt = DateTime.now().toUtc().toString();
    }
    _database
        .reference()
        .child('profile')
        .child(user.userId)
        .set(user.toJson());
    _userModel = user;
    if (_profileUserModel != null) {
      _profileUserModel = _userModel;
    }
    notifyListeners();
  }

  /// Fetch current user profile
  Future<FirebaseUser> getCurrentUser() async {
    try {
      loading = true;
      logEvent('get_currentUSer');
      user = await _firebaseAuth.currentUser();
      if (user != null) {
        authStatus = AuthStatus.LOGGED_IN;
        userId = user.uid;
        getProfileUser();
      } else {
        authStatus = AuthStatus.NOT_DETERMINED;
        loading = false;
      }
      return user;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getCurrentUser');
      authStatus = AuthStatus.NOT_DETERMINED;
      return null;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    // user.sendEmailVerification();
  }

  /// Check if user's email is verified
  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  /// Send password reset link to email
  Future<void> forgetPassword(String email,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email).then((value) {
        customSnackBar(scaffoldKey,
            'A reset password link is sent yo your mail.You can reset your password from there');
        logEvent('forgot+password');
      }).catchError((error) {
        cprint(error.message);
        return false;
      });
    } catch (error) {
      customSnackBar(scaffoldKey, error.message);
      return Future.value(false);
    }
  }

  /// `Update user` profile
  Future<void> updateUserProfile(User userModel, {File image}) async {
    try {
      if (image == null) {
        createUser(userModel);
      } else {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('user/profile/${Path.basename(image.path)}');
        StorageUploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.onComplete.then((value) {
          storageReference.getDownloadURL().then((fileURL) async {
            print(fileURL);
            UserUpdateInfo updateInfo = UserUpdateInfo();
            updateInfo.displayName = userModel?.displayName ?? user.displayName;
            updateInfo.photoUrl = fileURL;
            await user.updateProfile(updateInfo);
            if (userModel != null) {
              userModel.profilePic = fileURL;
              createUser(userModel);
            } else {
              _userModel.profilePic = fileURL;
              createUser(_userModel);
            }
          });
        });
      }
      logEvent('update_user');
    } catch (error) {
      cprint(error, errorIn: 'updateUserProfile');
    }
  }

  /// Fetch user profile
  getProfileUser({String userProfileId}) {
    try {
      loading = true;
      _profileUserModel = null;
      userProfileId = userProfileId == null ? userId : userProfileId;
      _database
          .reference()
          .child("profile")
          .child(userProfileId)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            _profileUserModel = User.fromJson(map);
            if (userProfileId == userId) {
              _userModel = _profileUserModel;
            }
            // Fecth following list to calculate following count
            getFollowingUser();
            logEvent('get_profile');
          }
        }
      // loading = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  /// Get following user
  getFollowingUser() {
    try {
      loading = true;
      if (profileUserModel != null && profileUserModel.userId.isNotEmpty) {
        profileFollowingList = null;
        _database
            .reference()
            .child("followList")
            .child(profileUserModel.userId)
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            profileFollowingList = [];
            var map = snapshot.value;
            if (map != null) {
              map['following'].forEach((key, value) {
                profileFollowingList.add(key);
              });
              if (profileUserModel.userId == userId) {
                _userModel.following = profileFollowingList.length;
                userfollowingList = profileFollowingList;
              } else {
                profileUserModel.following = profileFollowingList.length;
              }

            }
          } else {
            if (profileUserModel.userId == userId) {
              // If logged-in user didn't follow anyone
              // Show tweets only self tweets on home page.
              userfollowingList = null;
            }
          }
         loading = false;
        });
      }
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  /// Follow / Unfollow user
  ///
  /// If `removeFollower` is true then remove user from follower list
  ///
  /// If `removeFollower` is false then add user to follower list
  followUser({bool removeFollower = false}) {
    /// `userModel` is user who is looged-in app.
    /// `profileUserModel` is user whoose profile is open in app.
    try {
      if (removeFollower) {
        /// If logged-in user `alredy follow `profile user then
        /// 1.Remove logged-in user from profile user's `follower` list
        /// 2.Remove profile user from logged-in user's `following` list
        profileUserModel.followersList.remove(userModel.userId);

        // update user follower count
        profileUserModel.followers = profileUserModel.followersList.length;

        /// Remove profile user from logged-in user following list
        _database
            .reference()
            .child("followList")
            .child(userModel.userId)
            .child("following")
            .child(profileUserModel.userId)
            .remove();

        userfollowingList.remove(profileUserModel.userId);
        cprint('user removed from following list', event: 'remove_follow');
      } else {
        /// if logged in user is `not following` profile user then
        /// 1.Add logged in user to profile user's `follower` list
        /// 2. Add profile user to logged in user's `following` list
        if (profileUserModel.followersList == null) {
          profileUserModel.followersList = [userModel.userId];
        } else {
          profileUserModel.followersList.add(userModel.userId);
        }
        profileUserModel.followers = profileUserModel.followersList.length;
        // Adding profile user to logged-in user's following list
        _database
            .reference()
            .child("followList")
            .child(userModel.userId)
            .child("following")
            .child(profileUserModel.userId)
            .set({"userId": profileUserModel.userId});

        if (userfollowingList == null) {
          userfollowingList = [];
        }
        userfollowingList.add(profileUserModel.userId);

        cprint('user added to following list', event: 'add_follow');
      }
      // uppdate profile-user's by adding/removing follower
      _database
          .reference()
          .child('profile')
          .child(profileUserModel.userId)
          .set(profileUserModel.toJson());

      // update logged-in user'e following count
      userModel.following = userfollowingList.length;
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'followUser');
    }
  }

  void _onProfileChanged(Event event) {
    if (event.snapshot != null) {
      _userModel = User.fromJson(event.snapshot.value);
      cprint('User Updated');
      notifyListeners();
    }
  }
}
