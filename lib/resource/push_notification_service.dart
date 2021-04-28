import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/push_notification_model.dart';
import 'package:rxdart/rxdart.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging;

  PushNotificationService(this._firebaseMessaging) {
    initializeMessages();
  }

  PublishSubject<PushNotificationModel> _pushNotificationSubject;

  Stream<PushNotificationModel> get pushNotificationResponseStream =>
      _pushNotificationSubject.stream;

  void initializeMessages() {
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    configure();
  }

  /// Configure the firebase messaging handler
  void configure() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      myBackgroundMessageHandler(message, onMessage: true);
    }, onLaunch: (Map<String, dynamic> message) async {
      myBackgroundMessageHandler(message, onLaunch: true);
    }, onResume: (Map<String, dynamic> message) async {
      myBackgroundMessageHandler(message, onResume: true);
    });
    _pushNotificationSubject = PublishSubject<PushNotificationModel>();
  }

  /// Return FCM token
  Future<String> getDeviceToken() async {
    final token = await _firebaseMessaging.getToken();
    return token;
  }

  /// Callback triger everytime a push notification is received
  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message,
      {bool onBackGround = false,
      bool onLaunch = false,
      bool onMessage = false,
      bool onResume = false}) async {
    try {
      if (!onMessage &&
          message["data"] != null &&
          message["notification"] != null) {
        PushNotificationModel model = PushNotificationModel.fromJson(message);
        _pushNotificationSubject.add(model);
      }
    } catch (error) {
      cprint(error, errorIn: "myBackgroundMessageHandler");
    }
  }
}
