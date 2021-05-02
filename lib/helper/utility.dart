import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customLoader.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

final kAnalytics = FirebaseAnalytics();
final DatabaseReference kDatabase = FirebaseDatabase.instance.reference();
final kScreenloader = CustomLoader();
void cprint(dynamic data, {String errorIn, String event}) {
  /// Print logs only in development mode
  if (kDebugMode) {
    if (errorIn != null) {
      print(
          '****************************** error ******************************');
      developer.log('[Error]',
          time: DateTime.now(), error: data, name: errorIn);
      print(
          '****************************** error ******************************');
    } else if (data != null) {
      developer.log(
        data,
        time: DateTime.now(),
      );
    }
    if (event != null) {
      Utility.logEvent(event);
    }
  }
}

class Utility {
  static String getPostTime2(String date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    var dt = DateTime.parse(date).toLocal();
    var dat =
        DateFormat.jm().format(dt) + ' - ' + DateFormat("dd MMM yy").format(dt);
    return dat;
  }

  static String getdob(String date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    var dt = DateTime.parse(date).toLocal();
    var dat = DateFormat.yMMMd().format(dt);
    return dat;
  }

  static String getJoiningDate(String date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    var dt = DateTime.parse(date).toLocal();
    var dat = DateFormat("MMMM yyyy").format(dt);
    return 'Joined $dat';
  }

  static String getChatTime(String date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    String msg = '';
    var dt = DateTime.parse(date).toLocal();

    if (DateTime.now().toLocal().isBefore(dt)) {
      return DateFormat.jm().format(DateTime.parse(date).toLocal()).toString();
    }

    var dur = DateTime.now().toLocal().difference(dt);
    if (dur.inDays > 0) {
      msg = '${dur.inDays} d';
      return dur.inDays == 1 ? '1d' : DateFormat("dd MMM").format(dt);
    } else if (dur.inHours > 0) {
      msg = '${dur.inHours} h';
    } else if (dur.inMinutes > 0) {
      msg = '${dur.inMinutes} m';
    } else if (dur.inSeconds > 0) {
      msg = '${dur.inSeconds} s';
    } else {
      msg = 'now';
    }
    return msg;
  }

  static String getPollTime(String date) {
    int hr, mm;
    String msg = 'Poll ended';
    var enddate = DateTime.parse(date);
    if (DateTime.now().isAfter(enddate)) {
      return msg;
    }
    msg = 'Poll ended in';
    var dur = enddate.difference(DateTime.now());
    hr = dur.inHours - dur.inDays * 24;
    mm = dur.inMinutes - (dur.inHours * 60);
    if (dur.inDays > 0) {
      msg = ' ' + dur.inDays.toString() + (dur.inDays > 1 ? ' Days ' : ' Day');
    }
    if (hr > 0) {
      msg += ' ' + hr.toString() + ' hour';
    }
    if (mm > 0) {
      msg += ' ' + mm.toString() + ' min';
    }
    return (dur.inDays).toString() +
        ' Days ' +
        ' ' +
        hr.toString() +
        ' Hours ' +
        mm.toString() +
        ' min';
  }

  static String getSocialLinks(String url) {
    if (url != null && url.isNotEmpty) {
      url = url.contains("https://www") || url.contains("http://www")
          ? url
          : url.contains("www") &&
                  (!url.contains('https') && !url.contains('http'))
              ? 'https://' + url
              : 'https://www.' + url;
    } else {
      return null;
    }
    cprint('Launching URL : $url');
    return url;
  }

  static launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      cprint('Could not launch $url');
    }
  }

  static void logEvent(String event, {Map<String, dynamic> parameter}) {
    kReleaseMode
        ? kAnalytics.logEvent(name: event, parameters: parameter)
        : print("[EVENT]: $event");
  }

  static void debugLog(String log, {dynamic param = ""}) {
    final String time = DateFormat("mm:ss:mmm").format(DateTime.now());
    print("[$time][Log]: $log, $param");
  }

  static void share(String message, {String subject}) {
    Share.share(message, subject: subject);
  }

  static List<String> getHashTags(String text) {
    RegExp reg = RegExp(
        r"([#])\w+|(https?|ftp|file|#)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    Iterable<Match> _matches = reg.allMatches(text);
    List<String> resultMatches = <String>[];
    for (Match match in _matches) {
      if (match.group(0).isNotEmpty) {
        var tag = match.group(0);
        resultMatches.add(tag);
      }
    }
    return resultMatches;
  }

  static String getUserName({
    String id,
    String name,
  }) {
    String userName = '';
    if (name.length > 15) {
      name = name.substring(0, 6);
    }
    name = name.split(' ')[0];
    id = id.substring(0, 4).toLowerCase();
    userName = '@$name$id';
    return userName;
  }

  static bool validateCredentials(
      GlobalKey<ScaffoldState> _scaffoldKey, String email, String password) {
    if (email == null || email.isEmpty) {
      customSnackBar(_scaffoldKey, 'Please enter email id');
      return false;
    } else if (password == null || password.isEmpty) {
      customSnackBar(_scaffoldKey, 'Please enter password');
      return false;
    } else if (password.length < 8) {
      customSnackBar(_scaffoldKey, 'Password must me 8 character long');
      return false;
    }

    var status = validateEmal(email);
    if (!status) {
      customSnackBar(_scaffoldKey, 'Please enter valid email id');
      return false;
    }
    return true;
  }

  static customSnackBar(GlobalKey<ScaffoldState> _scaffoldKey, String msg,
      {double height = 30, Color backgroundColor = Colors.black}) {
    if (_scaffoldKey == null || _scaffoldKey.currentState == null) {
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        msg,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  static bool validateEmal(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    var status = regExp.hasMatch(email);
    return status;
  }

  static Future<Uri> createLinkToShare(BuildContext context, String id,
      {SocialMetaTagParameters socialMetaTagParameters}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://fwitterdev.page.link',
        link: Uri.parse('https://twitter.com/$id'),
        androidParameters: AndroidParameters(
          packageName: 'com.thealphamerc.flutter_twitter_clone_dev',
          minimumVersion: 0,
        ),
        dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
        ),
        socialMetaTagParameters: socialMetaTagParameters);
    Uri url;
    if (true) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
      return url;
    } else {
      url = await parameters.buildUrl();
    }
  }

  static createLinkAndShare(BuildContext context, String id,
      {SocialMetaTagParameters socialMetaTagParameters}) async {
    var url = await createLinkToShare(context, id,
        socialMetaTagParameters: socialMetaTagParameters);

    share(url.toString(), subject: "Tweet");
  }

  static shareFile(List<String> path, {String text = ""}) {
    try {
      Share.shareFiles(path, text: text);
    } catch (error) {
      print(error);
    }
  }

  static void copyToClipBoard({
    GlobalKey<ScaffoldState> scaffoldKey,
    String text,
    String message,
  }) {
    assert(message != null);
    assert(text != null);
    var data = ClipboardData(text: text);
    Clipboard.setData(data);
    customSnackBar(scaffoldKey, message);
  }
}
