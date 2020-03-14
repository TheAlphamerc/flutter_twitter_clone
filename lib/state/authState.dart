import 'dart:io';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  bool isSignInWithGoogle = false;

  String userId;
  FirebaseUser user;
  User _userModel;
  User _profileUserModel;
  User get userModel => _userModel;
  User get profileUserModel => _profileUserModel;
  dabase.Query _authQuery;
   void logoutCallback() {
       authStatus = AuthStatus.NOT_DETERMINED;
       userId = '';
       _userModel = null;
       _profileUserModel = null;
       if(isSignInWithGoogle){
         _googleSignIn.signOut();
       }else{
         _auth.signOut();
       }
       notifyListeners();
   }
   void openSignUpPage(){
     authStatus = AuthStatus.NOT_LOGGED_IN;
      userId = '';
      notifyListeners();
   }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
   databaseInit() {
    try {
      if (_authQuery == null) {
        _authQuery = _database.reference().child("feed");
        _authQuery.onChildChanged.listen(_onProfileChanged);
      }
    } catch (error) {
      cprint(error);
    }
  }
  Future<String> signIn(String email, String password,{GlobalKey<ScaffoldState> scaffoldKey }) async {
    try{
         var result = await _firebaseAuth.signInWithEmailAndPassword(
         email: email, password: password);
         user = result.user;
         userId = user.uid;
        return user.uid;
    }catch(error){
      cprint(error);
      customSnackBar(scaffoldKey,error.message);
      // logoutCallback();
      return null;
    }
  }
  Future<FirebaseUser> handleGoogleSignIn() async {
    try{
        final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
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
    }
    catch(error){
      cprint(error);
      return null;
    }
 }
 createUserFromGoogleSignIn(FirebaseUser user){
   User model = User(
     bio: 'Edit profile to update bio',
     dob:  DateTime(1950,DateTime.now().month,DateTime.now().day+3).toString(),
     location: 'Somewhere in universe',
     profilePic: user.photoUrl,
     displayName: user.displayName,
     email: user.email,
     key: user.uid,
     userId: user.uid,
     contact: user.phoneNumber,
     isVerified: true
   );
   createUser(model);
 }
  Future<String> signUp(User userModel,{GlobalKey<ScaffoldState> scaffoldKey,  String password }) async {
    try{
          var result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: userModel.email, password: password,);
          user = result.user;
          authStatus = AuthStatus.LOGGED_IN;

          UserUpdateInfo updateInfo = UserUpdateInfo();
          updateInfo.displayName = userModel.displayName;
          updateInfo.photoUrl = userModel.profilePic;
          await result.user.updateProfile(updateInfo);
          _userModel = userModel;
          _userModel.key = user.uid;
          _userModel.userId = user.uid;
          createUser(_userModel, newUser:true);
          return user.uid;
    }catch(error){
      cprint(error.message);
       customSnackBar(scaffoldKey,error.message);
      return null;
    }
  }

  /// `Create` and `Update` user
  /// IF `newUser` is true new user is created
  /// Else existing user will update with new values
  createUser(User user, {bool newUser = false}){
   
    if(newUser){
       // Create username by the combination of name and id
      user.userName = getUserName(id: user.userId, name: user.displayName);
     
      // Time at which user is created 
      user.createdAt = DateTime.now().toUtc().toString();
    }
    FirebaseDatabase.instance
      .reference()
      .child('profile')
      .child(user.userId)
      .set(user.toJson());
      _userModel = user;
      if(_profileUserModel != null){
        _profileUserModel = _userModel;
      }
       notifyListeners();
  }
  
  Future<FirebaseUser> getCurrentUser() async {
   try{
       FirebaseUser user = await _firebaseAuth.currentUser();
       if(user != null){
         authStatus = AuthStatus.LOGGED_IN;
         userId = user.uid;
         getProfileUser();
       }
       else{
          authStatus = AuthStatus.NOT_DETERMINED;
       }
       notifyListeners();
       return user;
   }
   catch(error){
     cprint(error);
     authStatus = AuthStatus.NOT_DETERMINED;
     return null;
   }
  }
  
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    // user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }
 
  Future<void> forgetPassword(String email,{GlobalKey<ScaffoldState> scaffoldKey }) async {
     try{
       await _firebaseAuth.sendPasswordResetEmail(email:email).then((value){
          customSnackBar(scaffoldKey,'A reset password link is sent yo your mail.You can reset your password from there');
       }).catchError((error){
         print(error.message);
         return false;
       });
      
     }catch (error){
       customSnackBar(scaffoldKey, error.message);
       return Future.value(false);
     }
  }
  
  Future<void> updateUserProfile(User userModel,{File image})async{
   try{
     if(image == null){
       createUser(userModel);
     }
     else{
          StorageReference storageReference = FirebaseStorage.instance.ref().child('user/profile/${Path.basename(image.path)}');    
          StorageUploadTask uploadTask = storageReference.putFile(image);    
          await uploadTask.onComplete.then((value){
          storageReference.getDownloadURL().then((fileURL)async {    
              print(fileURL);
               UserUpdateInfo updateInfo = UserUpdateInfo();
               updateInfo.displayName = userModel?.displayName ?? user.displayName;
               updateInfo.photoUrl = fileURL;
               await user.updateProfile(updateInfo);
               if(userModel != null){
                   userModel.profilePic = fileURL;
                  createUser(userModel);
               }
               else{
                  _userModel.profilePic = fileURL;
                  createUser(_userModel);
               }
         });
      }); 
     }
   } catch(error){
     cprint(error);
   }  
  }

  getProfileUser({String userProfileId}){
    _profileUserModel = null;
    userProfileId = userProfileId == null ? userId : userProfileId ;
     FirebaseDatabase.instance.reference().child("profile").child(userProfileId).once().then((DataSnapshot snapshot) {
      if(snapshot.value != null){
             var map = snapshot.value;
             if(map != null){
                _profileUserModel = User.fromJson(map);
                if(userProfileId == userId){
                  _userModel = _profileUserModel;
                }
                notifyListeners();
             }
      }
    });
  }

  void _onProfileChanged(Event event) {
    if(event.snapshot != null){
      _userModel = User.fromJson(event.snapshot.value);
       cprint('USer Updated');
       notifyListeners();
    }
  }
  void getFolloersList(){
    String userProfileId;
    FirebaseDatabase.instance.reference().child("profile").child(userProfileId).once().then((DataSnapshot snapshot) {
      if(snapshot.value != null){
             var map = snapshot.value;
             if(map != null){
                _profileUserModel = User.fromJson(map);
                if(userProfileId == userId){
                  _userModel = _profileUserModel;
                }
                notifyListeners();
             }
      }
    });
  }

}