import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  SettingsAppBar({Key key, this.title,this.subtitle}) : super(key: key);
  final String title, subtitle;
  final Size appBarHeight = Size.fromHeight(60.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          customTitleText(
            title,
          ),
          Text(
            subtitle,
            style: TextStyle(color: AppColor.darkGrey, fontSize: 15),
          )
        ],
      ),
      iconTheme: IconThemeData(color: Colors.blue),
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => appBarHeight;
}
