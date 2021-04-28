import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_twitter_clone/helper/shared_prefrence_helper.dart';
import 'package:flutter_twitter_clone/resource/push_notification_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<SharedPreferenceHelper>(SharedPreferenceHelper());
  // getIt.registerSingleton<PushNotificationService>(
  //     PushNotificationService(FirebaseMessaging()));
}
