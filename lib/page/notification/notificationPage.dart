import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/notificationModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/notificationState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    var state = Provider.of<NotificationState>(context, listen: false);
    var authstate = Provider.of<AuthState>(context, listen: false);
    state.getDataFromDatabase(authstate.userId);
  }

  Widget _body() {
    var state = Provider.of<NotificationState>(context);
    var list = state.notificationList;
    if (list == null || list.isEmpty) {
      return Container();
    }
    return ListView.separated(
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) => _notificationRow(list[index]),
      separatorBuilder: (context, index) => Divider(
        height: 0,
      ),
      itemCount: list.length,
    );
  }

  void onSettingIconPressed() {
    cprint('Settings');
  }

  Widget _notificationRow(NotificationModel model) {
    var state = Provider.of<NotificationState>(context);
    return FutureBuilder(
      future: state.getTweetDetail(model.tweetKey),
      builder: (BuildContext context, AsyncSnapshot<FeedModel> snapshot) {
        if (snapshot.hasData) {
          var des = snapshot.data.description.length > 150
              ? snapshot.data.description.substring(0, 150) + '...'
              : snapshot.data.description;
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            color: TwitterColor.white,
            child:ListTile(
            onTap: () {
              Navigator.of(context)
                  .pushNamed('/FeedPostDetail/' + model.tweetKey);
            },
            title: _userList(snapshot.data.likeList),
            subtitle: Padding(
              padding: EdgeInsets.only(left: 60),
              child: UrlText(
                text: des,
                style: TextStyle(
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _userList(List<LikeList> list) {
    var length = list.length;
    if (list != null && list.length > 5) {
      list = list.take(5).toList();
    }
    List<String> name = [];
    var state = Provider.of<NotificationState>(context);
    var col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(width: 20),
            customIcon(context,
                icon: AppIcon.heartFill,
                iconColor: TwitterColor.ceriseRed,
                istwitterIcon: true,
                size: 25),
            SizedBox(width: 10),
            Row(
              children: list.map((x) {
                return FutureBuilder(
                  future: state.getuserDetail(x.userId),
                  //  initialData: InitialData,
                  builder:
                      (BuildContext context, AsyncSnapshot<User> snapshot) {
                    if (snapshot.hasData) {
                      name.add(snapshot.data.displayName);
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                '/ProfilePage/' + snapshot.data?.userId);
                          },
                          child: customImage(context, snapshot.data.profilePic,
                              height: 30),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 60, bottom: 5, top: 5),
          child: UrlText(
            text: '$length people like your Tweet',
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        )
      ],
    );
    return col;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.mystic,
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: customTitleText(
          'Notifications',
        ),
        icon: AppIcon.settings,
        onActionPressed: onSettingIconPressed,
      ),
      body: _body(),
    );
  }
}
