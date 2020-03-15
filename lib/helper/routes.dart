import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/main.dart';
import 'package:flutter_twitter_clone/page/message/newMessagePage.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/about/aboutTwitter.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/accessibility/accessibility.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/accountSettingsPage.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/contentPrefrences/contentPreference.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/contentPrefrences/trends/trendsPage.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/dataUsage/dataUsagePage.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/displaySettings/displayAndSoundPage.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/notifications/notificationPage.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/privacyAndSafety/directMessage/directMessage.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/privacyAndSafety/privacyAndSafetyPage.dart';
import 'package:flutter_twitter_clone/page/settings/accountSettings/proxy/proxyPage.dart';
import 'package:flutter_twitter_clone/page/settings/settingsAndPrivacyPage.dart';
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
  static dynamic route(){
      return {
          '/': (BuildContext context) =>   MyHomePage(),
      };
  }
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
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> FeedPostDetail(postId: postId,));
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
     else if(pathElements[1].contains('SettingsAndPrivacyPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> SettingsAndPrivacyPage());
     }
     else if(pathElements[1].contains('AccountSettingsPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> AccountSettingsPage());
     }
     else if(pathElements[1].contains('PrivacyAndSaftyPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> PrivacyAndSaftyPage());
     }
     else if(pathElements[1].contains('NotificationPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> NotificationPage());
     }
     else if(pathElements[1].contains('ContentPrefrencePage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> ContentPrefrencePage());
     }
     else if(pathElements[1].contains('DisplayAndSoundPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> DisplayAndSoundPage());
     }
     else if(pathElements[1].contains('DirectMessagesPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> DirectMessagesPage());
     }
     else if(pathElements[1].contains('TrendsPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> TrendsPage());
     }
     else if(pathElements[1].contains('DataUsagePage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> DataUsagePage());
     }
     else if(pathElements[1].contains('AccessibilityPage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> AccessibilityPage());
     }
     else if(pathElements[1].contains('ProxyPage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> ProxyPage());
     }
     else if(pathElements[1].contains('AboutPage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> AboutPage());
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