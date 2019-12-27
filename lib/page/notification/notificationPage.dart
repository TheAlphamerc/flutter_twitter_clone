import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';

class NotificationPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  NotificationPage({Key key,this.scaffoldKey}) : super(key: key);

  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Widget _body(){
    return Container();
  }
  
  void onSettingIconPressed(){
    cprint('Settings');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(scaffoldKey: widget.scaffoldKey,title: customTitleText('Notifications',),icon:AppIcon.settings,onActionPressed: onSettingIconPressed,),
      body:_body()
    );
  }
}