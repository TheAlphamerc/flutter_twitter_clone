import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'helper/customRoute.dart';
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

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  AuthState _authState = AuthState();
  FeedState _feedState = FeedState();
  AppState _appState = AppState();
  ChatState _chatState = ChatState();
 @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>( create: (_) =>_appState),
        ChangeNotifierProvider<AuthState>( create: (_) =>_authState),
        ChangeNotifierProvider<FeedState>( create: (_) =>_feedState),
        ChangeNotifierProvider<ChatState>( create: (_) =>_chatState),
      ],
      child:  MaterialApp(
        title: 'Flutter Demo',
        theme:AppTheme.apptheme,
        //  Theme.of(context).copyWith(
        //   appBarTheme: apptheme.appBarTheme, 
         
        //   backgroundColor: apptheme.backgroundColor,
        //   // colorScheme: apptheme.colorScheme,
        //   floatingActionButtonTheme:apptheme.floatingActionButtonTheme),
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
         onGenerateRoute: (RouteSettings settings) {
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
                return CustomRoute<bool>(builder:(BuildContext context)=> FeedPostDetail(postId: postId,));
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
          },
         onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => Scaffold(
                appBar: AppBar(title: customTitleText(settings.name.split('/')[1]),centerTitle: true,),
                body: Center(
                  child: Text('${settings.name.split('/')[1]} Comming soon..'),
                ),
              ),
        ),
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
    return Scaffold(
      body: SelectAuthMethod()
    );
  }
}
