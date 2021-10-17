import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/ui/page/settings/widgets/headerWidget.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

import 'widgets/settingsRowWidget.dart';

class SettingsAndPrivacyPage extends StatelessWidget {
  const SettingsAndPrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Settings and privacy',
        ),
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget(user.userName),
          const SettingRowWidget(
            "Account",
            navigateTo: 'AccountSettingsPage',
          ),
          const Divider(height: 0),
          const SettingRowWidget("Privacy and Policy",
              navigateTo: 'PrivacyAndSaftyPage'),
          const SettingRowWidget("Notification",
              navigateTo: 'NotificationPage'),
          const SettingRowWidget("Content prefrences",
              navigateTo: 'ContentPrefrencePage'),
          const HeaderWidget(
            'General',
            secondHeader: true,
          ),
          const SettingRowWidget("Display and Sound",
              navigateTo: 'DisplayAndSoundPage'),
          const SettingRowWidget("Data usage", navigateTo: 'DataUsagePage'),
          const SettingRowWidget("Accessibility",
              navigateTo: 'AccessibilityPage'),
          const SettingRowWidget("Proxy", navigateTo: "ProxyPage"),
          const SettingRowWidget(
            "About Fwitter",
            navigateTo: "AboutPage",
          ),
          const SettingRowWidget(
            null,
            showDivider: false,
            vPadding: 10,
            subtitle:
                'These settings affect all of your Fwitter accounts on this devce.',
          )
        ],
      ),
    );
  }
}
