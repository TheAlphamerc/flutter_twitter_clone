import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/page/feed/feedPage.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/chats/chatState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:flutter_twitter_clone/widgets/tweet.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.profileId}) : super(key: key);

  final String profileId;

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isMyProfile = false;
  int pageIndex = 0;

  @override
  void initState() {
    var authstate = Provider.of<AuthState>(context, listen: false);
    authstate.getProfileUser(userProfileId: widget.profileId);
    isMyProfile =
        widget.profileId == null || widget.profileId == authstate.userId;
    super.initState();
  }

  SliverAppBar getAppbar() {
    var authstate = Provider.of<AuthState>(
      context,
    );
    return SliverAppBar(
      expandedHeight: 180,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        PopupMenuButton<Choice>(
          onSelected: (d) {},
          itemBuilder: (BuildContext context) {
            return choices.map((Choice choice) {
              return PopupMenuItem<Choice>(
                value: choice,
                child: Text(choice.title),
              );
            }).toList();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: <Widget>[
            Container(height: 30, color: Colors.black),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: customNetworkImage(
                  'https://pbs.twimg.com/profile_banners/457684585/1510495215/1500x500',
                  fit: BoxFit.fill),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 5),
                        shape: BoxShape.circle),
                    child: customImage(
                      context,
                      authstate.profileUserModel.profilePic,
                      height: 80,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 60, right: 30),
                    child: Row(
                      children: <Widget>[
                        isMyProfile
                            ? Container(
                                height: 40,
                              )
                            : InkWell(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                onTap: () {
                                  if (!isMyProfile) {
                                     final chatState = Provider.of<ChatState>(context, listen: false);
                                     chatState.setChatUser = authstate.profileUserModel;
                                    Navigator.pushNamed(
                                        context, '/ChatScreenPage');
                                  }
                                },
                                child: Container(
                                  // margin: EdgeInsets.only(right: 20),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isMyProfile
                                              ? Colors.black87.withAlpha(180)
                                              : Colors.blue,
                                          width: 1),
                                      shape: BoxShape.circle),
                                  child: Icon(
                                    Icons.mail_outline,
                                    color: Colors.blue,
                                    size: 15,
                                  ),
                                ),
                              ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          onTap: () {
                            if (isMyProfile) {
                              Navigator.pushNamed(context, '/EditProfile');
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isMyProfile
                                      ? Colors.black87.withAlpha(180)
                                      : Colors.blue,
                                  width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isMyProfile ? 'Edit Profile' : 'Follow',
                              style: TextStyle(
                                  color: isMyProfile
                                      ? Colors.black87.withAlpha(180)
                                      : Colors.blue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(
      context,
    );
    var authstate = Provider.of<AuthState>(
      context,
    );
    List<FeedModel> list;
    String id = widget.profileId ?? authstate.userId;
    if (state.feedlist != null && state.feedlist.length > 0) {
      list = state.feedlist.where((x) => x.userId == id).toList();
    }
    return Scaffold(
      body: authstate.profileUserModel == null
          ? loader()
          : CustomScrollView(
              slivers: <Widget>[
                getAppbar(),
                UserNameRowWidget(
                  authstate: authstate,
                  isMyProfile: isMyProfile,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    list == null || list.length < 1
                        ? [
                            Container(
                              child: Center(
                                child: Text(
                                  'No tweet posted yet',
                                  style: subtitleStyle,
                                ),
                              ),
                            )
                          ]
                        : list
                            .map(
                              (x) => Tweet(model: x),
                            )
                            .toList(),
                  ),
                )
              ],
            ),
    );
  }
}

class UserNameRowWidget extends StatelessWidget {
  const UserNameRowWidget({
    Key key,
    @required this.authstate,
    @required this.isMyProfile,
  }) : super(key: key);

  final AuthState authstate;
  final bool isMyProfile;

  String getBio(String bio) {
    if (isMyProfile) {
      return bio;
    } else if (bio == "Edit profile to update bio") {
      return "No bio available";
    } else {
      return bio;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Row(
              children: <Widget>[
                UrlText(
                  text: authstate.profileUserModel.displayName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                authstate.profileUserModel.isVerified
                    ? customIcon(context,
                        icon: AppIcon.blueTick,
                        istwitterIcon: true,
                        iconColor: AppColor.primary,
                        size: 13,
                        paddingIcon: 3)
                    : SizedBox(
                        width: 0,
                      ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 9),
            child: customText(
              '${authstate.profileUserModel.userName}',
              style: subtitleStyle.copyWith(fontSize: 13),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: customText(
              getBio(authstate.profileUserModel.bio),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: <Widget>[
                Icon(Icons.location_city, size: 14, color: Colors.black54),
                SizedBox(
                  width: 10,
                ),
                customText(
                  authstate.profileUserModel.location,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: <Widget>[
                Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                SizedBox(
                  width: 10,
                ),
                customText(
                  getdob(authstate.profileUserModel.dob),
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 10,
                  height: 30,
                ),
                customText(
                  '${authstate.profileUserModel.followers} ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                customText(
                  'Followers',
                  style: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                SizedBox(
                  width: 40,
                ),
                customText(
                  '${authstate.profileUserModel.following} ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                customText(
                  'Following',
                  style: TextStyle(color: Colors.black54, fontSize: 17),
                ),
              ],
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final IconData icon;
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Share', icon: Icons.directions_car),
  const Choice(title: 'Draft', icon: Icons.directions_bike),
  const Choice(title: 'View Lists', icon: Icons.directions_boat),
  const Choice(title: 'View Moments', icon: Icons.directions_bus),
  const Choice(title: 'QR code', icon: Icons.directions_railway),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
