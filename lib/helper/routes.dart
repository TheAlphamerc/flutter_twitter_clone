import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/page/message/newMessagePage.dart';
import '../page/Auth/signin.dart';
import '../helper/customRoute.dart';
import '../page/feed/createFeed.dart';
import '../page/feed/imageViewPage.dart';
import '../page/SearchPage.dart';
import '../page/Auth/forgetPasswordPage.dart';
import '../page/Auth/signin.dart';
import '../page/Auth/signup.dart';
import '../page/feed/feedPostDetail.dart';
import '../page/feed/feedPostreply.dart';
import '../page/profile/EditProfilePage.dart';
import '../page/message/chatScreenPage.dart';
import '../page/profile/profilePage.dart';
import '../widgets/customWidgets.dart';

class Routes{
  static Route onGenerateRoute(RouteSettings settings) {
           final List<String> pathElements = settings.name.split('/');
           if (pathElements[0] != '' || pathElements.length == 1) {
               return null;
             }
             if(pathElements[1].contains('SignIn')){
               return CustomRoute<bool>(builder:(BuildContext context)=> SignIn());
             }
             else if(pathElements[1].contains('SignUp')){
               return CustomRoute<bool>(builder:(BuildContext context)=> Signup());
             }
             else if(pathElements[1].contains('SearchPage')){
                return CustomRoute<bool>(builder:(BuildContext context)=> SearchPage());
             }
             else if(pathElements[1].contains('CreateFeedPage')){
                return CustomRoute<bool>(builder:(BuildContext context)=> CreateFeedPage());
             }
             else if(pathElements[1].contains('FeedPostReplyPage')){
               var postId = pathElements[2];
                return CustomRoute<bool>(builder:(BuildContext context)=> FeedPostReplyPage(postId: postId,));
             }
             else if(pathElements[1].contains('FeedPostDetail')){
               var postId = pathElements[2];
                return CustomRoute<bool>(builder:(BuildContext context)=> FeedPostDetail(postId: postId,));
             }
            else if(pathElements[1].contains('ForgetPasswordPage')){
                return CustomRoute<bool>(builder:(BuildContext context)=> ForgetPasswordPage());
             }
             else if(pathElements[1].contains('ImageViewPge')){
                return CustomRoute<bool>(builder:(BuildContext context)=> ImageViewPge());
             }
             else if(pathElements[1].contains('ProfilePage')){
                String profileId;
               if(pathElements.length > 2){
                   profileId = pathElements[2];
               }
                return CustomRoute<bool>(builder:(BuildContext context)=> ProfilePage(profileId: profileId,));
             }
             else if(pathElements[1].contains('EditProfile')){
                return CustomRoute<bool>(builder:(BuildContext context)=> EditProfilePage());
             }
             else if(pathElements[1].contains('ChatScreenPage')){
                return CustomRoute<bool>(builder:(BuildContext context)=> ChatScreenPage());
             }
              else if(pathElements[1].contains('NewMessagePage')){
                return CustomRoute<bool>(builder:(BuildContext context)=> NewMessagePage());
             }
          }

   static Route onUnknownRoute(RouteSettings settings){
     return MaterialPageRoute(
          builder: (_) => Scaffold(
                appBar: AppBar(title: customTitleText(settings.name.split('/')[1]),centerTitle: true,),
                body: Center(
                  child: Text('${settings.name.split('/')[1]} Comming soon..'),
                ),
              ),
        );
   }
}