import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/shared_prefrence_helper.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/ui/page/common/locator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as Path;

import 'appState.dart';

class AuthState extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  bool isSignInWithGoogle = false;
  User user;
  String userId;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  dabase.Query _profileQuery;
  // List<UserModel> _profileUserModelList;
  UserModel _userModel;

  UserModel get userModel => _userModel;

  UserModel get profileUserModel => _userModel;

  /// Logout from device
  void logoutCallback() async {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    _userModel = null;
    user = null;
    _profileQuery.onValue.drain();
    _profileQuery = null;
    if (isSignInWithGoogle) {
      _googleSignIn.signOut();
      Utility.logEvent('google_logout');
    }
    _firebaseAuth.signOut();
    notifyListeners();
    await getIt<SharedPreferenceHelper>().clearPreferenceValues();
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
        _profileQuery = kDatabase.child("profile").child(user.uid);
        _profileQuery.onValue.listen(_onProfileChanged);
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
      kAnalytics.logLogin(loginMethod: 'email_login');
      Utility.customSnackBar(scaffoldKey, error.message);
      // logoutCallback();
      return null;
    }
  }

  /// Create user from `google login`
  /// If user is new then it create a new user
  /// If user is old then it just `authenticate` user and return firebase user data
  Future<User> handleGoogleSignIn() async {
    try {
      /// Record log in firebase kAnalytics about Google login
      kAnalytics.logLogin(loginMethod: 'google_login');
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google login cancelled by user');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = (await _firebaseAuth.signInWithCredential(credential)).user;
      authStatus = AuthStatus.LOGGED_IN;
      userId = user.uid;
      isSignInWithGoogle = true;
      createUserFromGoogleSignIn(user);
      notifyListeners();
      return user;
    } on PlatformException catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    } on Exception catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    } catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    }
  }

  /// Create user profile from google login
  createUserFromGoogleSignIn(User user) {
    var diff = DateTime.now().difference(user.metadata.creationTime);
    // Check if user is new or old
    // If user is new then add new user to firebase realtime kDatabase
    if (diff < Duration(seconds: 15)) {
      UserModel model = UserModel(
        bio: 'Edit profile to update bio',
        dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
            .toString(),
        location: 'Somewhere in universe',
        profilePic: user.photoURL,
        displayName: user.displayName,
        email: user.email,
        key: user.uid,
        userId: user.uid,
        contact: user.phoneNumber,
        isVerified: user.emailVerified,
      );
      createUser(model, newUser: true);
    } else {
      cprint('Last login at: ${user.metadata.lastSignInTime}');
    }
  }

  /// Create new user's profile in db
  Future<String> signUp(UserModel userModel,
      {GlobalKey<ScaffoldState> scaffoldKey, String password}) async {
    try {
      loading = true;
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );
      user = result.user;
      authStatus = AuthStatus.LOGGED_IN;
      kAnalytics.logSignUp(signUpMethod: 'register');
      result.user.updateProfile(
          displayName: userModel.displayName, photoURL: userModel.profilePic);

      _userModel = userModel;
      _userModel.key = user.uid;
      _userModel.userId = user.uid;
      createUser(_userModel, newUser: true);
      return user.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signUp');
      Utility.customSnackBar(scaffoldKey, error.message);
      return null;
    }
  }

  /// `Create` and `Update` user
  /// IF `newUser` is true new user is created
  /// Else existing user will update with new values
  createUser(UserModel user, {bool newUser = false}) {
    if (newUser) {
      // Create username by the combination of name and id
      user.userName =
          Utility.getUserName(id: user.userId, name: user.displayName);
      kAnalytics.logEvent(name: 'create_newUser');

      // Time at which user is created
      user.createdAt = DateTime.now().toUtc().toString();
    }

    kDatabase.child('profile').child(user.userId).set(user.toJson());
    _userModel = user;
    loading = false;
  }

  /// Fetch current user profile
  Future<User> getCurrentUser() async {
    try {
      loading = true;
      Utility.logEvent('get_currentUSer');
      user = _firebaseAuth.currentUser;
      if (user != null) {
        authStatus = AuthStatus.LOGGED_IN;
        userId = user.uid;
        getProfileUser();
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      }
      loading = false;
      return user;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getCurrentUser');
      authStatus = AuthStatus.NOT_LOGGED_IN;
      return null;
    }
  }

  /// Reload user to get refresh user data
  reloadUser() async {
    await user.reload();
    user = _firebaseAuth.currentUser;
    if (user.emailVerified) {
      userModel.isVerified = true;
      // If user verifed his email
      // Update user in firebase realtime kDatabase
      createUser(userModel);
      cprint('UserModel email verification complete');
      Utility.logEvent('email_verification_complete',
          parameter: {userModel.userName: user.email});
    }
  }

  /// Send email verification link to email2
  Future<void> sendEmailVerification(
      GlobalKey<ScaffoldState> scaffoldKey) async {
    User user = _firebaseAuth.currentUser;
    user.sendEmailVerification().then((_) {
      Utility.logEvent('email_verifcation_sent',
          parameter: {userModel.displayName: user.email});
      Utility.customSnackBar(
        scaffoldKey,
        'An email verification link is send to your email.',
      );
    }).catchError((error) {
      cprint(error.message, errorIn: 'sendEmailVerification');
      Utility.logEvent('email_verifcation_block',
          parameter: {userModel.displayName: user.email});
      Utility.customSnackBar(
        scaffoldKey,
        error.message,
      );
    });
  }

  /// Check if user's email is verified
  Future<bool> emailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  /// Send password reset link to email
  Future<void> forgetPassword(String email,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email).then((value) {
        Utility.customSnackBar(scaffoldKey,
            'A reset password link is sent yo your mail.You can reset your password from there');
        Utility.logEvent('forgot+password');
      }).catchError((error) {
        cprint(error.message);
        return false;
      });
    } catch (error) {
      Utility.customSnackBar(scaffoldKey, error.message);
      return Future.value(false);
    }
  }

  /// `Update user` profile
  Future<void> updateUserProfile(UserModel userModel,
      {File image, File bannerImage}) async {
    try {
      if (image == null && bannerImage == null) {
        createUser(userModel);
      } else {
        /// upload profile image if not null
        if (image != null) {
          /// get image storage path from server
          userModel.profilePic = await _uploadFileToStorage(image,
              'user/profile/${userModel.userName}/${Path.basename(image.path)}');
          // print(fileURL);
          var name = userModel?.displayName ?? user.displayName;
          _firebaseAuth.currentUser
              .updateProfile(displayName: name, photoURL: userModel.profilePic);
        }

        /// upload banner image if not null
        if (bannerImage != null) {
          /// get banner storage path from server
          userModel.bannerImage = await _uploadFileToStorage(bannerImage,
              'user/profile/${userModel.userName}/${Path.basename(bannerImage.path)}');
        }

        if (userModel != null) {
          createUser(userModel);
        } else {
          createUser(_userModel);
        }
      }

      Utility.logEvent('update_user');
    } catch (error) {
      cprint(error, errorIn: 'updateUserProfile');
    }
  }

  Future<String> _uploadFileToStorage(File file, path) async {
    var task = _firebaseStorage.ref().child(path);
    var status = await task.putFile(file);
    print(status.state);

    /// get file storage path from server
    return await task.getDownloadURL();
  }

  /// `Fetch` user `detail` whoose userId is passed
  Future<UserModel> getuserDetail(String userId) async {
    UserModel user;
    var snapshot = await kDatabase.child('profile').child(userId).once();
    if (snapshot.value != null) {
      var map = snapshot.value;
      user = UserModel.fromJson(map);
      user.key = snapshot.key;
      return user;
    } else {
      return null;
    }
  }

  /// Fetch user profile
  /// If `userProfileId` is null then logged in user's profile will fetched
  getProfileUser({String userProfileId}) {
    try {
      loading = true;

      userProfileId = userProfileId == null ? user.uid : userProfileId;
      kDatabase
          .child("profile")
          .child(userProfileId)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            if (userProfileId == user.uid) {
              _userModel = UserModel.fromJson(map);
              _userModel.isVerified = user.emailVerified;
              if (!user.emailVerified) {
                // Check if logged in user verified his email address or not
                reloadUser();
              }
              if (_userModel.fcmToken == null) {
                updateFCMToken();
              }

              getIt<SharedPreferenceHelper>().saveUserProfile(_userModel);
            }

            Utility.logEvent('get_profile');
          }
        }
        loading = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  /// if firebase token not available in profile
  /// Then get token from firebase and save it to profile
  /// When someone sends you a message FCM token is used
  void updateFCMToken() {
    if (_userModel == null) {
      return;
    }
    getProfileUser();
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      _userModel.fcmToken = token;
      createUser(_userModel);
    });
  }

  /// Trigger when logged-in user's profile change or updated
  /// Firebase event callback for profile update
  void _onProfileChanged(Event event) {
    if (event.snapshot != null) {
      final updatedUser = UserModel.fromJson(event.snapshot.value);
      _userModel = updatedUser;
      cprint('UserModel Updated');
      notifyListeners();
    }
  }
}
