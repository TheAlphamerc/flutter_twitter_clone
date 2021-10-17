import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({Key? key, required this.title, this.subtitle})
      : super(key: key);
  final String? subtitle;
  final String title;
  final Size appBarHeight = const Size.fromHeight(60.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 5),
          customTitleText(
            title,
          ),
          Text(
            subtitle ?? '',
            style: const TextStyle(color: AppColor.darkGrey, fontSize: 18),
          )
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.blue),
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => appBarHeight;
}
