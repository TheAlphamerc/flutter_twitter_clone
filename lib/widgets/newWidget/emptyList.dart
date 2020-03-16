import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import '../customWidgets.dart';

class EmptyList extends StatelessWidget {
  EmptyList(this.title, {this.subTitle});

  final String subTitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fullHeight(context) - 140,
      color: TwitterColor.mystic,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleText(title, fontSize: 25, textAlign: TextAlign.center),
          SizedBox(
            height: 20,
          ),
          TitleText(
            subTitle,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: TwitterColor.paleSky50,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
