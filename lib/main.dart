import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'helper/customRoute.dart';
import 'helper/routes.dart';
import 'page/Auth/selectAuthMethod.dart';
import 'page/feed/createFeed.dart';
import 'page/feed/imageViewPage.dart';
import 'page/SearchPage.dart';
import 'state/appState.dart';
import 'package:provider/provider.dart';
import 'page/Auth/forgetPasswordPage.dart';
import 'page/Auth/signin.dart';
import 'page/Auth/signup.dart';
import 'page/feed/feedPostDetail.dart';
import 'page/feed/feedPostreply.dart';
import 'page/profile/EditProfilePage.dart';
import 'page/message/chatScreenPage.dart';
import 'page/profile/profilePage.dart';
import 'state/authState.dart';
import 'state/chats/chatState.dart';
import 'state/feedState.dart';
import 'widgets/customWidgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
        ChangeNotifierProvider<FeedState>(create: (_) => FeedState()),
        ChangeNotifierProvider<ChatState>(create: (_) => ChatState()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.apptheme,
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
        onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
        onUnknownRoute: (settings) => Routes.onUnknownRoute(settings),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SelectAuthMethod());
  }
}
