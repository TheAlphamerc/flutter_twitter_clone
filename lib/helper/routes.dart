import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/page/Auth/selectAuthMethod.dart';
import 'package:flutter_twitter_clone/page/Auth/verifyEmail.dart';
import 'package:flutter_twitter_clone/page/common/splash.dart';
import 'package:flutter_twitter_clone/page/message/conversationInformation/conversationInformation.dart';
import 'package:flutter_twitter_clone/page/message/newMessagePage.dart';
import 'package:flutter_twitter_clone/page/profile/follow/followerListPage.dart';
import 'package:flutter_twitter_clone/page/profile/follow/followingListPage.dart';
import 'package:flutter_twitter_clone/page/search/SearchPage.dart';
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
import '../page/Auth/forgetPasswordPage.dart';
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
          '/': (BuildContext context) =>   SplashPage(),
      };
  }

  static void sendNavigationEventToFirebase(String path) {
    if(path != null && path.isNotEmpty){
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route onGenerateRoute(RouteSettings settings) {
     final List<String> pathElements = settings.name.split('/');
     if (pathElements[0] != '' || pathElements.length == 1) {
       return null;
     }
     if(pathElements[1].contains('SignIn')){
       return CustomRoute<bool>(
         builder:(BuildContext context)=> SignIn(),
         settings: RouteSettings(name:'SignIn')
         );
     }
     else if(pathElements[1].contains('WelcomePage')){
       return CustomRoute<bool>(builder:(BuildContext context)=> WelcomePage(),settings: RouteSettings(name:'WelcomePage'));
     }
     else if(pathElements[1].contains('SignUp')){
       return CustomRoute<bool>(builder:(BuildContext context)=> Signup(),settings: RouteSettings(name:'Signup'));
     }
     else if(pathElements[1].contains('SearchPage')){
        return CustomRoute<bool>(builder:(BuildContext context)=> SearchPage(),settings: RouteSettings(name:'SearchPage'));
     }
     else if(pathElements[1].contains('CreateFeedPage')){
        return CustomRoute<bool>(builder:(BuildContext context)=> CreateFeedPage(),settings: RouteSettings(name:'CreateFeedPage'));
     }
     else if(pathElements[1].contains('FeedPostReplyPage')){
       var postId = pathElements[2];
        return CustomRoute<bool>(builder:(BuildContext context)=> FeedPostReplyPage(postId: postId,),settings: RouteSettings(name:'FeedPostReplyPage'));
     }
     else if(pathElements[1].contains('FeedPostDetail')){
       var postId = pathElements[2];
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> FeedPostDetail(postId: postId,),settings: RouteSettings(name:'FeedPostDetail'));
     }
    else if(pathElements[1].contains('ForgetPasswordPage')){
        return CustomRoute<bool>(builder:(BuildContext context)=> ForgetPasswordPage(),settings: RouteSettings(name:'ForgetPasswordPage'));
     }
     else if(pathElements[1].contains('ImageViewPge')){
        return CustomRoute<bool>(builder:(BuildContext context)=> ImageViewPge(),settings: RouteSettings(name:'ImageViewPge'));
     }
     else if(pathElements[1].contains('ProfilePage')){
        String profileId;
       if(pathElements.length > 2){
           profileId = pathElements[2];
       }
        return CustomRoute<bool>(builder:(BuildContext context)=> ProfilePage(profileId: profileId,),settings: RouteSettings(name:'ProfilePage'));
     }
     else if(pathElements[1].contains('EditProfile')){
        return CustomRoute<bool>(builder:(BuildContext context)=> EditProfilePage(),settings: RouteSettings(name:'EditProfile'));
     }
     else if(pathElements[1].contains('ChatScreenPage')){
        return CustomRoute<bool>(builder:(BuildContext context)=> ChatScreenPage(),settings: RouteSettings(name:'ChatScreenPage'));
     }
     else if(pathElements[1].contains('NewMessagePage')){
        return CustomRoute<bool>(builder:(BuildContext context)=> NewMessagePage(),settings: RouteSettings(name:'NewMessagePage'));
     }
     else if(pathElements[1].contains('SettingsAndPrivacyPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> SettingsAndPrivacyPage(),settings: RouteSettings(name:'SettingsAndPrivacyPage'));
     }
     else if(pathElements[1].contains('AccountSettingsPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> AccountSettingsPage(),settings: RouteSettings(name:'AccountSettingsPage'));
     }
     else if(pathElements[1].contains('PrivacyAndSaftyPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> PrivacyAndSaftyPage(),settings: RouteSettings(name:'PrivacyAndSaftyPage'));
     }
     else if(pathElements[1].contains('NotificationPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> NotificationPage(),settings: RouteSettings(name:'NotificationPage'));
     }
     else if(pathElements[1].contains('ContentPrefrencePage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> ContentPrefrencePage(),settings: RouteSettings(name:'ContentPrefrencePage'));
     }
     else if(pathElements[1].contains('DisplayAndSoundPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> DisplayAndSoundPage(),settings: RouteSettings(name:'DisplayAndSoundPage'));
     }
     else if(pathElements[1].contains('DirectMessagesPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> DirectMessagesPage(),settings: RouteSettings(name:'DirectMessagesPage'));
     }
     else if(pathElements[1].contains('TrendsPage')){
        return SlideLeftRoute<bool>(builder:(BuildContext context)=> TrendsPage(),settings: RouteSettings(name:'TrendsPage'));
     }
     else if(pathElements[1].contains('DataUsagePage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> DataUsagePage(),settings: RouteSettings(name:'DataUsagePage'));
     }
     else if(pathElements[1].contains('AccessibilityPage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> AccessibilityPage(),settings: RouteSettings(name:'AccessibilityPage'));
     }
     else if(pathElements[1].contains('ProxyPage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> ProxyPage(),settings: RouteSettings(name:'ProxyPage'));
     }
     else if(pathElements[1].contains('AboutPage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> AboutPage(),settings: RouteSettings(name:'AboutPage'));
     }
      else if(pathElements[1].contains('ConversationInformation')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> ConversationInformation(),settings: RouteSettings(name:'ConversationInformation'));
     }
     else if(pathElements[1].contains('FollowingListPage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> FollowingListPage(),settings: RouteSettings(name:'FollowingListPage'));
     }
     else if(pathElements[1].contains('FollowerListPage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> FollowerListPage(),settings: RouteSettings(name:'FollowerListPage'));
     }
     else if(pathElements[1].contains('VerifyEmailPage')){
       return SlideLeftRoute<bool>(builder:(BuildContext context)=> VerifyEmailPage(),settings: RouteSettings(name:'VerifyEmailPage'));
     }
     else{
       return onUnknownRoute(RouteSettings(name: '/Feature'));
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