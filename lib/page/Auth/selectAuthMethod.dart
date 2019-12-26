import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/page/Auth/signup.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:provider/provider.dart';
import '../homePage.dart';
import 'signin.dart';

class SelectAuthMethod extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SelectAuthMethodState();
  
}
class _SelectAuthMethodState extends State<SelectAuthMethod> {
  @override
  void initState() {
     var state = Provider.of<AuthState>(context,listen: false);
     state.authStatus = AuthStatus.NOT_DETERMINED;
    //  state.getCurrentUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return Scaffold(
       body:
      //  state.authStatus == AuthStatus.NOT_DETERMINED ? 
      //  SignIn() :
       state.authStatus == AuthStatus.NOT_DETERMINED?
       SignIn(loginCallback: state.getCurrentUser,) 
       : state.authStatus == AuthStatus.NOT_LOGGED_IN ?
         Signup(loginCallback: state.getCurrentUser)  
       : HomePage()  
       
    );
  }
}