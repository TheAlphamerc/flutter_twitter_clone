import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/page/settings/widgets/headerWidget.dart';
import 'package:flutter_twitter_clone/page/settings/widgets/settingsRowWidget.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Trends',
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          SettingRowWidget(
            "Trends location",
            navigateTo: null,
            subtitle: 'New York',
            showDivider: false,
          ),
          SettingRowWidget(
            null,
            subtitle: 'You can see what\'s trending in a specfic location by selecting which location appears in your Trending tab.',
            navigateTo:null,
            showDivider: false,
            vPadding: 12,
            ),
        ],
      ),
    );
  }
}
