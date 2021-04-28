import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/push_notification_model.dart';
import 'package:flutter_twitter_clone/resource/push_notification_service.dart';
import 'package:flutter_twitter_clone/ui/page/feed/feedPage.dart';
import 'package:flutter_twitter_clone/ui/page/message/chatListPage.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/chats/chatState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/state/notificationState.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';
import 'package:flutter_twitter_clone/ui/page/profile/profilePage.dart';
import 'package:flutter_twitter_clone/widgets/bottomMenuBar/bottomMenuBar.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'common/locator.dart';
import 'common/sidebar.dart';
import 'notification/notificationPage.dart';
import 'search/SearchPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  int pageIndex = 0;
  // ignore: cancel_subscriptions
  StreamSubscription<PushNotificationModel> pushNotificationSubscription;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<AppState>(context, listen: false);
      state.setpageIndex = 0;
      initTweets();
      initProfile();
      initSearch();
      initNotificaiton();
      initChat();
    });

    super.initState();
  }

  @override
  void dispose() {
    // getIt<PushNotificationService>().pushBehaviorSubject.close();
    super.dispose();
  }

  void initTweets() {
    var state = Provider.of<FeedState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void initProfile() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.databaseInit();
  }

  void initSearch() {
    var searchState = Provider.of<SearchState>(context, listen: false);
    searchState.getDataFromDatabase();
  }

  void initNotificaiton() {
    var state = Provider.of<NotificationState>(context, listen: false);
    var authstate = Provider.of<AuthState>(context, listen: false);
    state.databaseInit(authstate.userId);

    /// configure push notifications
    state.initfirebaseService();

    /// Suscribe the push notifications
    /// Whenever devices recieve push notifcation, `listenPushNotification` callback will trigger.
    pushNotificationSubscription = getIt<PushNotificationService>()
        .pushNotificationResponseStream
        .listen(listenPushNotification);
  }

  /// Listen for every push notifications when app is in background
  /// Check for push notifications when app is launched by tapping on push notifications from system tray.
  /// If notification type is `NotificationType.Message` then chat screen will open
  /// If notification type is `NotificationType.Mention` then user profile will open who taged/mentioned you in a tweet
  void listenPushNotification(PushNotificationModel model) {
    final authstate = Provider.of<AuthState>(context, listen: false);
    var state = Provider.of<NotificationState>(context, listen: false);

    /// Check if user recieve chat notification
    /// Redirect to chat screen
    /// `model.data.senderId` is a user id who sends you a message
    /// `model.data.receiverId` is a your user id.
    if (model.data.type == NotificationType.Message.toString() &&
        model.data.receiverId == authstate.user.uid) {
      /// Get sender profile detail from firebase
      state.getuserDetail(model.data.senderId).then((user) {
        final chatState = Provider.of<ChatState>(context, listen: false);
        chatState.setChatUser = user;
        Navigator.pushNamed(context, '/ChatScreenPage');
      });
    }

    /// Checks for user tag tweet notification
    /// If you are mentioned in tweet then it redirect to user profile who mentioed you in a tweet
    /// You can check that tweet on his profile timeline
    /// `model.data.senderId` is user id who tagged you in a tweet
    else if (model.data.type == NotificationType.Mention.toString() &&
        model.data.receiverId == authstate.user.uid) {
      Navigator.push(
          context, ProfilePage.getRoute(profileId: model.data.senderId));
    }
  }

  void initChat() {
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    chatState.databaseInit(state.userId, state.userId);

    /// It will update fcm token in database
    /// fcm token is required to send firebase notification
    state.updateFCMToken();

    /// It get fcm server key
    /// Server key is required to configure firebase notification
    /// Without fcm server notification can not be sent
    chatState.getFCMServerKey();
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        child: _getPage(Provider.of<AppState>(context).pageIndex),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return FeedPage(
          scaffoldKey: _scaffoldKey,
          refreshIndicatorKey: refreshIndicatorKey,
        );
        break;
      case 1:
        return SearchPage(scaffoldKey: _scaffoldKey);
        break;
      case 2:
        return NotificationPage(scaffoldKey: _scaffoldKey);
        break;
      case 3:
        return ChatListPage(scaffoldKey: _scaffoldKey);
        break;
      default:
        return FeedPage(scaffoldKey: _scaffoldKey);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomMenubar(),
      drawer: SidebarMenu(),
      body: _body(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<StreamSubscription<PushNotificationModel>>(
            'pushNotificationSubscription', pushNotificationSubscription));
  }
}
