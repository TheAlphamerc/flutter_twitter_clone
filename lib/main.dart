import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/state/chats/chatUserState.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';
import 'helper/routes.dart';
import 'state/appState.dart';
import 'package:provider/provider.dart';
import 'state/authState.dart';
import 'state/feedState.dart';
import 'package:google_fonts/google_fonts.dart';

import 'state/notificationState.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        ChangeNotifierProvider<ChatUserState>(create: (_) => ChatUserState()),
        ChangeNotifierProvider<SearchState>(create: (_) => SearchState()),
        ChangeNotifierProvider<NotificationState>(
            create: (_) => NotificationState()),
      ],
      child: MaterialApp(
        title: 'Fwitter',
        theme: AppTheme.apptheme.copyWith(
          textTheme: GoogleFonts.muliTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        debugShowCheckedModeBanner: false,
        routes: Routes.route(),
        onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
        onUnknownRoute: (settings) => Routes.onUnknownRoute(settings),
      ),
    );
  }
}
