import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';

Widget customTitleText(String title, {BuildContext context}) {
  return Text(
    title ?? '',
    style: TextStyle(
      color: Colors.black87,
      fontFamily: 'HelveticaNeue',
      fontWeight: FontWeight.w900,
      fontSize: 20,
    ),
  );
}

Widget customIcon(
  BuildContext context, {
  IconData icon,
  bool isEnable = false,
  double size = 18,
  bool istwitterIcon = true,
  bool isFontAwesomeSolid = false,
  Color iconColor,
  double paddingIcon = 10,
}) {
  iconColor = iconColor ?? Theme.of(context).textTheme.caption.color;
  return Padding(
    padding: EdgeInsets.only(bottom: istwitterIcon ? paddingIcon : 0),
    child: Icon(
      icon,
      size: size,
      color: isEnable ? Theme.of(context).primaryColor : iconColor,
    ),
  );
}

Widget customText(String msg,
    {Key key,
    TextStyle style,
    TextAlign textAlign = TextAlign.justify,
    TextOverflow overflow = TextOverflow.visible,
    BuildContext context,
    bool softwrap = true}) {
  if (msg == null) {
    return SizedBox(
      height: 0,
      width: 0,
    );
  } else {
    if (context != null && style != null) {
      var fontSize =
          style.fontSize ?? Theme.of(context).textTheme.bodyText1.fontSize;
      style = style.copyWith(
        fontSize: fontSize - (context.width <= 375 ? 2 : 0),
      );
    }
    return Text(
      msg,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softwrap,
      key: key,
    );
  }
}

Widget loader() {
  if (Platform.isIOS) {
    return Center(
      child: CupertinoActivityIndicator(),
    );
  } else {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }
}
