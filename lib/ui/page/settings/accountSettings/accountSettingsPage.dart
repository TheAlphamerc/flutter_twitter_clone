import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/ui/page/settings/widgets/headerWidget.dart';
import 'package:flutter_twitter_clone/ui/page/settings/widgets/settingsAppbar.dart';
import 'package:flutter_twitter_clone/ui/page/settings/widgets/settingsRowWidget.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: SettingsAppBar(
        title: 'Account',
        subtitle: user?.userName,
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget('Login and security'),
          SettingRowWidget(
            "Username",
            subtitle: user?.userName,
            // navigateTo: 'AccountSettingsPage',
          ),
          Divider(height: 0),
          SettingRowWidget(
            "Phone",
            subtitle: user?.contact,
          ),
          SettingRowWidget(
            "Email address",
            subtitle: user?.email,
            navigateTo: 'VerifyEmailPage',
          ),
          SettingRowWidget("Password"),
          SettingRowWidget("Security"),
          HeaderWidget(
            'Data and Permission',
            secondHeader: true,
          ),
          SettingRowWidget("Country"),
          SettingRowWidget("Your Fwitter data"),
          SettingRowWidget("Apps and sessions"),
          SettingRowWidget(
            "Log out",
            textColor: TwitterColor.ceriseRed,
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              final state = Provider.of<AuthState>(context);
              state.logoutCallback();
            },
          ),
        ],
      ),
    );
  }
}
