// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/ui/page/Auth/selectAuthMethod.dart';
import 'package:flutter_twitter_clone/ui/page/Auth/verifyEmail.dart';
import 'package:flutter_twitter_clone/ui/page/common/splash.dart';
import 'package:flutter_twitter_clone/ui/page/feed/composeTweet/composeTweet.dart';
import 'package:flutter_twitter_clone/ui/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:flutter_twitter_clone/ui/page/homePage.dart';
import 'package:flutter_twitter_clone/ui/page/message/conversationInformation/conversationInformation.dart';
import 'package:flutter_twitter_clone/ui/page/message/newMessagePage.dart';
import 'package:flutter_twitter_clone/ui/page/profile/follow/followerListPage.dart';
import 'package:flutter_twitter_clone/ui/page/search/SearchPage.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/about/aboutTwitter.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/accessibility/accessibility.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/accountSettingsPage.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/contentPrefrences/contentPreference.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/contentPrefrences/trends/trendsPage.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/dataUsage/dataUsagePage.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/displaySettings/displayAndSoundPage.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/notifications/notificationPage.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/privacyAndSafety/directMessage/directMessage.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/privacyAndSafety/privacyAndSafetyPage.dart';
import 'package:flutter_twitter_clone/ui/page/settings/accountSettings/proxy/proxyPage.dart';
import 'package:flutter_twitter_clone/ui/page/settings/settingsAndPrivacyPage.dart';
import 'package:provider/provider.dart';

import '../helper/customRoute.dart';
import '../ui/page/Auth/forgetPasswordPage.dart';
import '../ui/page/Auth/signin.dart';
import '../ui/page/Auth/signup.dart';
import '../ui/page/feed/feedPostDetail.dart';
import '../ui/page/feed/imageViewPage.dart';
import '../ui/page/message/chatScreenPage.dart';
import '../ui/page/profile/profilePage.dart';
import '../widgets/customWidgets.dart';

class Routes {
  static dynamic route() {
    return {
      'SplashPage': (BuildContext context) => const SplashPage(),
    };
  }

  static void sendNavigationEventToFirebase(String? path) {
    if (path != null && path.isNotEmpty) {
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name!.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "ComposeTweetPage":
        bool isRetweet = false;
        bool isTweet = false;
        if (pathElements.length == 3 && pathElements[2].contains('retweet')) {
          isRetweet = true;
        } else if (pathElements.length == 3 &&
            pathElements[2].contains('tweet')) {
          isTweet = true;
        }
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child:
                      ComposeTweetPage(isRetweet: isRetweet, isTweet: isTweet),
                ));
      case "FeedPostDetail":
        var postId = pathElements[2];
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => FeedPostDetail(
                  postId: postId,
                ),
            settings: const RouteSettings(name: 'FeedPostDetail'));
      case "ProfilePage":
        String profileId;
        if (pathElements.length > 2) {
          profileId = pathElements[2];
          return CustomRoute<bool>(
              builder: (BuildContext context) => ProfilePage(
                    profileId: profileId,
                  ));
        }
        return CustomRoute(builder: (BuildContext context) => const HomePage());

      case "CreateFeedPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child:
                      const ComposeTweetPage(isRetweet: false, isTweet: true),
                ));
      case "WelcomePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const WelcomePage());
      case "SignIn":
        return CustomRoute<bool>(builder: (BuildContext context) => SignIn());
      case "SignUp":
        return CustomRoute<bool>(builder: (BuildContext context) => Signup());
      case "ForgetPasswordPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const ForgetPasswordPage());
      case "SearchPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => SearchPage());
      case "ImageViewPge":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const ImageViewPge());
      case "ChatScreenPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const ChatScreenPage());
      case "NewMessagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => NewMessagePage(),
        );
      case "SettingsAndPrivacyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const SettingsAndPrivacyPage(),
        );
      case "AccountSettingsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const AccountSettingsPage(),
        );
      case "PrivacyAndSaftyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const PrivacyAndSaftyPage(),
        );
      case "NotificationPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const NotificationPage(),
        );
      case "ContentPrefrencePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const ContentPrefrencePage(),
        );
      case "DisplayAndSoundPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const DisplayAndSoundPage(),
        );
      case "DirectMessagesPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const DirectMessagesPage(),
        );
      case "TrendsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const TrendsPage(),
        );
      case "DataUsagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const DataUsagePage(),
        );
      case "AccessibilityPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const AccessibilityPage(),
        );
      case "ProxyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const ProxyPage(),
        );
      case "AboutPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const AboutPage(),
        );
      case "ConversationInformation":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const ConversationInformation(),
        );
      case "FollowerListPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => FollowerListPage(),
        );
      case "VerifyEmailPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => VerifyEmailPage(),
        );
      default:
        return onUnknownRoute(const RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: customTitleText(
            settings.name!.split('/')[1],
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name!.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}
