import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/page/settings/widgets/headerWidget.dart';
import 'package:flutter_twitter_clone/page/settings/widgets/settingsAppbar.dart';
import 'package:flutter_twitter_clone/page/settings/widgets/settingsRowWidget.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class ContentPrefrencePage extends StatelessWidget {
  const ContentPrefrencePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: SettingsAppBar(
        title: 'Content preferences',
        subtitle: user.userName,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget('Explore'),
          SettingRowWidget(
            "Trends",
            navigateTo: 'TrendsPage',
          ),
          Divider(height: 0),
          SettingRowWidget(
            "Search settings",
            navigateTo: null,
          ),
          HeaderWidget(
            'Languages',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Recommendations",
            vPadding: 15,
            subtitle:
                "Select which language you want recommended Tweets, people, and trends to include",
          ),
          HeaderWidget(
            'Safety',
            secondHeader: true,
          ),
          SettingRowWidget("Blocked accounts"),
          SettingRowWidget("Muted accounts"),
        ],
      ),
    );
  }
}
