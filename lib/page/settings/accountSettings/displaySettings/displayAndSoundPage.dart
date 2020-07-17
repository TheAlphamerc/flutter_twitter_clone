import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/page/settings/widgets/headerWidget.dart';
import 'package:flutter_twitter_clone/page/settings/widgets/settingsRowWidget.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';

class DisplayAndSoundPage extends StatelessWidget {
  const DisplayAndSoundPage({Key key}) : super(key: key);

  void openBottomSheet(
    BuildContext context,
    double height,
    Widget child,
  ) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: TwitterColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: child,
        );
      },
    );
  }

  void openDarkModeSettings(BuildContext context) {
    openBottomSheet(
      context,
      250,
      Column(
        children: <Widget>[
          SizedBox(height: 5),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: TwitterColor.paleSky50,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TitleText('Dark Mode'),
          ),
          Divider(height: 0),
          _row("On"),
          Divider(height: 0),
          _row("Off"),
          Divider(height: 0),
          _row("Automatic at sunset"),
        ],
      ),
    );
  }

  void openDarkModeAppearanceSettings(BuildContext context) {
    openBottomSheet(
      context,
      190,
      Column(
        children: <Widget>[
          SizedBox(height: 5),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: TwitterColor.paleSky50,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TitleText('Dark mode appearance'),
          ),
          Divider(height: 0),
          _row("Dim"),
          Divider(height: 0),
          _row("Light out"),
        ],
      ),
    );
  }

  Widget _row(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: RadioListTile(
        value: false,
        groupValue: true,
        onChanged: (val) {},
        title: Text(text),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Display and Sound',
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget('Media'),
          SettingRowWidget(
            "Media Previews",
            showCheckBox: false,
          ),
          Divider(height: 0),
          HeaderWidget('Display'),
          SettingRowWidget(
            "Dark Mode",
            subtitle: 'Off',
            onPressed: () {
              openDarkModeSettings(context);
            },
            showDivider: false,
          ),
          SettingRowWidget(
            "Dark Mode appearance",
            subtitle: 'Dim',
            onPressed: () {
              openDarkModeAppearanceSettings(context);
            },
            showDivider: false,
          ),
          SettingRowWidget(
            "Emoji",
            subtitle:
                'Use the Fwitter set instead of your device\'s default set',
            showDivider: false,
            showCheckBox: false,
          ),
          HeaderWidget(
            'Sound',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Sound effects",
            // vPadding: 15,
            showCheckBox: false,
          ),
          HeaderWidget(
            'Web browser',
            secondHeader: false,
          ),
          SettingRowWidget(
            "Use in-app browser",
            subtitle: 'Open external links with Fwitter browser',
            showCheckBox: false,
          ),
        ],
      ),
    );
  }
}
