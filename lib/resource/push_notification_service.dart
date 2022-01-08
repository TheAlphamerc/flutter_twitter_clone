import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/push_notification_model.dart';
import 'package:rxdart/rxdart.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  cprint("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging;

  PushNotificationService(this._firebaseMessaging) {
    initializeMessages();
  }

  late PublishSubject<PushNotificationModel> _pushNotificationSubject;

  Stream<PushNotificationModel> get pushNotificationResponseStream =>
      _pushNotificationSubject.stream;

  // ignore: unused_field, cancel_subscriptions
  late StreamSubscription<RemoteMessage> _backgroundMessageSubscription;

  void initializeMessages() {
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(sound: true, badge: true, alert: true));
    configure();
  }

  /// Configured from Home page
  void configure() async {
    _pushNotificationSubject = PublishSubject<PushNotificationModel>();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      cprint('Got a message whilst in the foreground!');

      try {
        // var data = json.decode(message.data.toString()) as Map<String, dynamic>;
        myBackgroundMessageHandler(message.data, onMessage: true);
      } catch (e) {
        cprint(e, errorIn: "On Message");
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// Get message when the app is in the Terminated form
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        try {
          myBackgroundMessageHandler(event.data, onLaunch: true);
        } catch (e) {
          cprint(e, errorIn: "On getInitialMessage");
        }
      }
    });

    /// Returns a [Stream] that is called when a user presses a notification message displayed via FCM.
    _backgroundMessageSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? event) {
      if (event != null) {
        try {
          myBackgroundMessageHandler(event.data, onLaunch: true);
        } catch (e) {
          cprint(e, errorIn: "On onMessageOpenedApp");
        }
      }
    });
  }

  /// Return FCM token
  Future<String?> getDeviceToken() async {
    final token = await _firebaseMessaging.getToken();
    return token;
  }

  /// Callback triger everytime a push notification is received
  void myBackgroundMessageHandler(Map<String, dynamic> message,
      {bool onBackGround = false,
      bool onLaunch = false,
      bool onMessage = false,
      bool onResume = false}) async {
    try {
      if (!onMessage) {
        PushNotificationModel model = PushNotificationModel.fromJson(message);
        _pushNotificationSubject.add(model);
      }
    } catch (error) {
      cprint(error, errorIn: "myBackgroundMessageHandler");
    }
  }
}
