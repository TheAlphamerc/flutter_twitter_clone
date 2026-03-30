## Fwitter - แอปพลิเคชันโคลน Twitter ใน Flutter [![GitHub stars](https://img.shields.io/github/stars/Thealphamerc/flutter_twitter_clone?style=social)](https://github.com/login?return_to=%2FTheAlphamerc%flutter_twitter_clone) ![GitHub forks](https://img.shields.io/github/forks/TheAlphamerc/flutter_twitter_clone?style=social) 

แอปพลิเคชัน Twitter Clone ที่ใช้งานได้จริง สร้างด้วย Flutter โดยใช้ Firebase auth, realtime, firestore database และ storage

<a href="https://play.google.com/store/apps/details?id=com.thealphamerc.flutter_twitter_clone">
  <img width="100%" alt="Fwitter Banner" src="https://user-images.githubusercontent.com/37103237/152671482-885fd940-f4ea-4fb6-8baf-816c17b541d7.png">
</a>

![Dart CI](https://github.com/TheAlphamerc/flutter_twitter_clone/workflows/Dart%20CI/badge.svg) ![GitHub pull requests](https://img.shields.io/github/issues-pr/TheAlphamerc/flutter_twitter_clone) ![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed/Thealphamerc/flutter_twitter_clone) ![GitHub last commit](https://img.shields.io/github/last-commit/Thealphamerc/flutter_twitter_clone)  ![GitHub issues](https://img.shields.io/github/issues-raw/Thealphamerc/flutter_twitter_clone) [![Open Source Love](https://badges.frapsoft.com/os/v2/open-source.svg?v=103)](https://github.com/TheAlphamerc/flutter_twitter_clone) 

<a href="https://github.com/Solido/awesome-flutter#top">
   <img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square" />
</a>

## ดาวน์โหลดแอปพลิเคชัน
<a href="https://play.google.com/store/apps/details?id=com.thealphamerc.flutter_twitter_clone"><img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="200"></img></a>

## คุณสมบัติ
* คุณสมบัติของแอปพลิเคชันมีรายละเอียดอยู่ที่หัวข้อโครงการ [คลิกที่นี่](https://github.com/TheAlphamerc/flutter_twitter_clone/projects/1)
* สถานะของส่วนแชทข้อความสามารถดูได้ที่ [ที่นี่](https://github.com/TheAlphamerc/flutter_twitter_clone/projects/2)

 :boom: แอปพลิเคชัน Fwitter ใช้ทั้ง firebase `realtime` และ `firestore` database:boom:
* ในสาขา **firestore** Fwitter ใช้ `Firestore` database สำหรับแอป
* ในสาขา **master** และ **realtime_db** Fwitter ใช้ `Firebase Realtime` database สำหรับแอป

## ส่วนขึ้นต่อกัน
<details>
     <summary> คลิกเพื่อขยาย </summary>
     
* [intl](https://pub.dev/packages/intl)
* [uuid](https://pub.dev/packages/uuid)
* [http](https://pub.dev/packages/http)
* [share](https://pub.dev/packages/share)
* [provider](https://pub.dev/packages/provider)
* [url_launcher](https://pub.dev/packages/url_launcher)
* [google_fonts](https://pub.dev/packages/google_fonts)
* [image_picker](https://pub.dev/packages/image_picker)
* [firebase_auth](https://pub.dev/packages/firebase_auth)
* [google_sign_in](https://pub.dev/packages/google_sign_in)
* [firebase_analytics](https://pub.dev/packages/firebase_analytics)
* [firebase_database](https://pub.dev/packages/firebase_database)
* [shared_preferences](https://pub.dev/packages/shared_preferences)
* [flutter_advanced_networkimage](https://pub.dev/packages/flutter_advanced_networkimage)
     
</details>

## ภาพหน้าจอ

หน้ายินดีต้อนรับ | หน้าเข้าสู่ระบบ | หน้าสมัครสมาชิก | หน้าลืมรหัสผ่าน
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Auth/screenshot_1.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Auth/screenshot_2.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Auth/screenshot_3.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Auth/screenshot_4.jpg?raw=true)|

หน้าแรกแถบด้านข้าง | หน้าแรก | หน้าแรก | หน้าแรก
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Home/screenshot_5.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Home/screenshot_2.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Home/screenshot_7.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Home/screenshot_6.jpg?raw=true)|

หน้าเขียน Tweet | ตอบกลับ Tweet | ตอบกลับ Tweet | เขียน Retweet พร้อมความเห็น
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/CreateTweet/screenshot_1.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/CreateTweet/screenshot_2.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/CreateTweet/screenshot_4.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/CreateTweet/screenshot_3.jpg?raw=true)|

หน้ารายละเอียด Tweet | สาย Tweet | สาย Tweet ที่ซ้อนกัน | ตัวเลือก Tweet
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/TweetDetail/screenshot_3.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/TweetDetail/screenshot_4.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/TweetDetail/screenshot_1.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/TweetDetail/screenshot_2.jpg?raw=true)|

หน้าการแจ้งเตือน | หน้าการแจ้งเตือน | หน้าการแจ้งเตือน | หน้าการตั้งค่าการแจ้งเตือน
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Notification/screenshot_1.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Notification/screenshot_2.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Notification/screenshot_3.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Notification/screenshot_4.jpg?raw=true)|

หน้าโปรไฟล์ | หน้าโปรไฟล์ | หน้าโปรไฟล์ | หน้าโปรไฟล์
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Profile/screenshot_1.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Profile/screenshot_2.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Profile/screenshot_4.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Profile/screenshot_7.jpg?raw=true)|

เลือกหน้าผู้ใช้ | หน้าแชท | รายชื่อผู้ใช้แชท | หน้าข้อมูลการสนทนา
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Chat/screenshot_1.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Chat/screenshot_2.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Chat/screenshot_3.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Chat/screenshot_4.jpg?raw=true)|

หน้าค้นหา | หน้าการตั้งค่าการค้นหา | ตัวเลือก Tweet - 1 | ตัวเลือก Tweet - 2
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Search/screenshot_1.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Search/screenshot_2.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/TweetDetail/screenshot_5.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/TweetDetail/screenshot_6.jpg?raw=true)|

หน้าการตั้งค่า | หน้าการตั้งค่าบัญชี | หน้าการตั้งค่าความเป็นส่วนตัว | หน้าการตั้งค่าความเป็นส่วนตัว
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_1.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_2.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_4.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_3.jpg?raw=true)|

หน้าการตั้งค่ากำหนดความหมาย | หน้าการตั้งค่าการแสดงผล | หน้าการตั้งค่าการใช้ข้อมูล | หน้าการตั้งค่าการเข้าถึง
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_5.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_6.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_7.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_8.jpg?raw=true)|

ผู้ใช้ที่ชอบ Tweet | หน้าการตั้งค่าเกี่ยวกับ | การตั้งค่าใบอนุญาต | การตั้งค่า
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/TweetDetail/screenshot_7.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_9.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_10.jpg?raw=true)|![](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/screenshots/Settings/screenshot_81.jpg?raw=true)|

## เริ่มต้น
* คำแนะนำในการตั้งค่าโครงการมีให้ที่หัวข้อ [Wiki](https://github.com/TheAlphamerc/flutter_twitter_clone/wiki/Gettings-Started)

## โครงสร้างไดเรกทอรี่
<details>
     <summary> คลิกเพื่อขยาย </summary>
   
```
|-- lib
|   |-- helper
|   |   |-- constant.dart
|   |   |-- customRoute.dart
|   |   |-- enum.dart
|   |   |-- routes.dart
|   |   |-- theme.dart
|   |   |-- utility.dart
|   |   '-- validator.dart
|   |-- main.dart
|   |-- model
|   |   |-- chatModel.dart
|   |   |-- feedModel.dart
|   |   |-- notificationModel.dart
|   |   '-- user.dart
|   |-- page
|   |   |-- Auth
|   |   |   |-- forgetPasswordPage.dart
|   |   |   |-- selectAuthMethod.dart
|   |   |   |-- signin.dart
|   |   |   |-- signup.dart
|   |   |   |-- verifyEmail.dart
|   |   |   '-- widget
|   |   |       '-- googleLoginButton.dart
|   |   |-- common
|   |   |   |-- sidebar.dart
|   |   |   |-- splash.dart
|   |   |   |-- usersListPage.dart
|   |   |   '-- widget
|   |   |       '-- userListWidget.dart
|   |   |-- feed
|   |   |   |-- composeTweet
|   |   |   |   |-- composeTweet.dart
|   |   |   |   |-- state
|   |   |   |   |   '-- composeTweetState.dart
|   |   |   |   '-- widget
|   |   |   |       |-- composeBottomIconWidget.dart
|   |   |   |       |-- composeTweetImage.dart
|   |   |   |       '-- widgetView.dart
|   |   |   |-- feedPage.dart
|   |   |   |-- feedPostDetail.dart
|   |   |   '-- imageViewPage.dart
|   |   |-- homePage.dart
|   |   |-- message
|   |   |   |-- chatListPage.dart
|   |   |   |-- chatScreenPage.dart
|   |   |   |-- conversationInformation
|   |   |   |   '-- conversationInformation.dart
|   |   |   '-- newMessagePage.dart
|   |   |-- notification
|   |   |   '-- notificationPage.dart
|   |   |-- profile
|   |   |   |-- EditProfilePage.dart
|   |   |   |-- follow
|   |   |   |   |-- followerListPage.dart
|   |   |   |   '-- followingListPage.dart
|   |   |   |-- profileImageView.dart
|   |   |   |-- profilePage.dart
|   |   |   '-- widgets
|   |   |       '-- tabPainter.dart
|   |   |-- search
|   |   |   '-- SearchPage.dart
|   |   '-- settings
|   |       |-- accountSettings
|   |       |   |-- about
|   |       |   |   '-- aboutTwitter.dart
|   |       |   |-- accessibility
|   |       |   |   '-- accessibility.dart
|   |       |   |-- accountSettingsPage.dart
|   |       |   |-- contentPrefrences
|   |       |   |   |-- contentPreference.dart
|   |       |   |   '-- trends
|   |       |   |       '-- trendsPage.dart
|   |       |   |-- dataUsage
|   |       |   |   '-- dataUsagePage.dart
|   |       |   |-- displaySettings
|   |       |   |   '-- displayAndSoundPage.dart
|   |       |   |-- notifications
|   |       |   |   '-- notificationPage.dart
|   |       |   |-- privacyAndSafety
|   |       |   |   |-- directMessage
|   |       |   |   |   '-- directMessage.dart
|   |       |   |   '-- privacyAndSafetyPage.dart
|   |       |   '-- proxy
|   |       |       '-- proxyPage.dart
|   |       |-- settingsAndPrivacyPage.dart
|   |       '-- widgets
|   |           |-- headerWidget.dart
|   |           |-- settingsAppbar.dart
|   |           '-- settingsRowWidget.dart
|   |-- state
|   |   |-- appState.dart
|   |   |-- authState.dart
|   |   |-- chats
|   |   |   '-- chatState.dart
|   |   |-- feedState.dart
|   |   |-- notificationState.dart
|   |   '-- searchState.dart
|   '-- widgets
|       |-- bottomMenuBar
|       |   |-- HalfPainter.dart
|       |   |-- bottomMenuBar.dart
|       |   '-- tabItem.dart
|       |-- customAppBar.dart
|       |-- customWidgets.dart
|       |-- newWidget
|       |   |-- customClipper.dart
|       |   |-- customLoader.dart
|       |   |-- customProgressbar.dart
|       |   |-- customUrlText.dart
|       |   |-- emptyList.dart
|       |   |-- rippleButton.dart
|       |   '-- title_text.dart
|       '-- tweet
|           |-- tweet.dart
|           '-- widgets
|               |-- parentTweet.dart
|               |-- retweetWidget.dart
|               |-- tweetBottomSheet.dart
|               |-- tweetIconsRow.dart
|               |-- tweetImage.dart
|               '-- unavailableTweet.dart
|-- pubspec.yaml
```

</details>
     
## การมีส่วนร่วม

หากคุณต้องการนำเสนอการเปลี่ยนแปลงไปยังคุณสมบัติที่มีอยู่หรือเพิ่มคุณสมบัติใหม่ในที่เก็บนี้
โปรดตรวจสอบ [คำแนะนำการมีส่วนร่วม](https://github.com/TheAlphamerc/flutter_twitter_clone/blob/master/CONTRIBUTING.md) ของเรา
และส่ง [pull request](https://github.com/TheAlphamerc/flutter_twitter_clone/pulls) ฉันยินดีต้อนรับและสนับสนุนคำขอดึงข้อมูลทั้งหมด โดยปกติจะใช้เวลา 24-48 ชั่วโมงในการตอบสนองต่อปัญหาหรือคำขอใด ๆ

## สร้างและบำรุงรักษาโดย

[Sonu Sharma](https://github.com/TheAlphamerc) ([Twitter](https://www.twitter.com/TheAlphamerc)) ([Youtube](https://www.youtube.com/user/sonusharma045sonu/)) ([Insta](https://www.instagram.com/_sonu_sharma__)) ([Dev.to](https://dev.to/thealphamerc))
  ![Twitter Follow](https://img.shields.io/twitter/follow/thealphamerc?style=social) 

> หากคุณพบว่าโครงการนี้มีประโยชน์หรือคุณได้เรียนรู้สิ่งต่างๆ จากซอร์สโค้ดและต้องการขอบคุณฉัน โปรดพิจารณาซื้อกาแฟให้ฉัน :coffee:
>
> * [PayPal](https://paypal.me/TheAlphamerc/)

> คุณยังสามารถเสนอชื่อฉันสำหรับโปรแกรม Github Star developer
> https://stars.github.com/nominate

## ผู้มีส่วนร่วม
* [TheAlphamerc](https://github.com/TheAlphamerc/TheAlphamerc)
* [Liel Beigel](https://github.com/lielb100)
* [Riccardo Montagnin](https://github.com/RiccardoM)
* [Suriyan](https://github.com/imsuriyan)
* [Liel Beigel](https://github.com/lielb100)
* [Rodriguezv](https://github.com/aa-rodriguezv)

## จำนวนผู้เข้าชม

<img align="left" src = "https://profile-counter.glitch.me/flutter_twitter_clone/count.svg" alt ="Loading">