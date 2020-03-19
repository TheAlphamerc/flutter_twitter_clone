import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/notificationState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class UserListWidget extends StatelessWidget {
  final List<String> list;
  final String emptyScreenText;
  const UserListWidget({Key key, this.list, this.emptyScreenText})
      : super(key: key);
  Widget _userTile(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          // onTap: () {
          //   Navigator.of(context).pushNamed('/ProfilePage/' + user?.userId);
          // },
          leading: customImage(context, user.profilePic, height: 60),
          title: Row(
            children: <Widget>[
              UrlText(
                text: user.displayName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 3),
              user.isVerified
                  ? customIcon(
                      context,
                      icon: AppIcon.blueTick,
                      istwitterIcon: true,
                      iconColor: AppColor.primary,
                      size: 13,
                      paddingIcon: 3,
                    )
                  : SizedBox(width: 0),
            ],
          ),
          subtitle: Text(user.userName),
          trailing: OutlineButton(
            onPressed: () {},
            child: TitleText(
              'Follow',
              color: TwitterColor.dodgetBlue_50,
              fontSize: 18,
            ),
            color: TwitterColor.dodgetBlue_50,
            borderSide: BorderSide(
              color: TwitterColor.dodgetBlue_50,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 90),
          child: Text(
            getBio(user.bio),
          ),
        )
      ],
    );
  }

  String getBio(String bio) {
    if (bio != null && bio.isNotEmpty) {
      if (bio.length > 100) {
        bio = bio.substring(0, 100) + '...';
        return bio;
      } else {
        return bio;
      }
    } else if (bio == "Edit profile to update bio") {
      return "No bio available";
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    var notificationState = Provider.of<NotificationState>(context);
    return list != null && list.isNotEmpty
        ? ListView.separated(
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: notificationState.getuserDetail(list[index]),
                builder: (context, AsyncSnapshot<User> snapshot) {
                  if (snapshot.hasData) {
                    return _userTile(context, snapshot.data);
                  } else {
                    return Center(
                      child: LinearProgressIndicator(),
                    );
                  }
                },
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: list.length,
          )
        : Container(
            width: fullWidth(context),
            padding: EdgeInsets.only(top: 0, left: 30, right: 30),
            child: NotifyText(
              title: emptyScreenText,
              subTitle: '',
            ),
          );
  }
}
