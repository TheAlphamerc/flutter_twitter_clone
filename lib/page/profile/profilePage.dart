import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/page/feed/feedPage.dart';
import 'package:flutter_twitter_clone/page/feed/widgets/tweetBottomSheet.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/chats/chatState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
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
            SizedBox.expand(
              child: Container(
                padding: EdgeInsets.only(top: 50),
                height: 30,
                color: Colors.white,
              ),
            ),
            Container(height: 50, color: Colors.black),
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
                                    final chatState = Provider.of<ChatState>(
                                        context,
                                        listen: false);
                                    chatState.setChatUser =
                                        authstate.profileUserModel;
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
                        SizedBox(width: 20),
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

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage');
      },
      child: customIcon(
        context,
        icon: AppIcon.fabTweet,
        istwitterIcon: true,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    var authstate = Provider.of<AuthState>(context);
    List<FeedModel> list;
    String id = widget.profileId ?? authstate.userId;
    if (state.feedlist != null && state.feedlist.length > 0) {
      list = state.feedlist.where((x) => x.userId == id).toList();
    }
    return Scaffold(
      backgroundColor: list != null && list.isNotEmpty
          ? TwitterColor.mystic
          : TwitterColor.white,
      floatingActionButton: isMyProfile ? _floatingActionButton() : null,
      body: authstate.profileUserModel == null
          ? loader()
          : 
          CustomScrollView(
            physics: ClampingScrollPhysics(),
              slivers: <Widget>[
                getAppbar(),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: UserNameRowWidget(
                      user: authstate.profileUserModel,
                      isMyProfile: isMyProfile,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    list == null || list.length < 1
                        ? [
                            Container(
                              padding:
                                  EdgeInsets.only(top: 50, left: 30, right: 30),
                              child: NotifyText(
                                title: 'No tweet posted by you yet',
                                subTitle: 'Tap tweet button to add new',
                              ),
                            )
                          ]
                        : list
                            .map(
                              (x) => Container(
                                color: TwitterColor.white,
                                child: Tweet(
                                  model: x,
                                  isDisplayOnProfile: true,
                                  trailing: TweetBottomSheet().tweetOptionIcon(
                                      context, x, TweetType.Tweet),
                                ),
                              ),
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
    @required this.user,
    @required this.isMyProfile,
  }) : super(key: key);

  final User user;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(
            children: <Widget>[
              UrlText(
                text: user.displayName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(
                width: 3,
              ),
              user.isVerified
                  ? customIcon(context,
                      icon: AppIcon.blueTick,
                      istwitterIcon: true,
                      iconColor: AppColor.primary,
                      size: 13,
                      paddingIcon: 3)
                  : SizedBox(width: 0),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 9),
          child: customText(
            '${user.userName}',
            style: subtitleStyle.copyWith(fontSize: 13),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: customText(
            getBio(user.bio),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              customIcon(context,
                  icon: AppIcon.locationPin,
                  size: 14,
                  istwitterIcon: true,
                  paddingIcon: 5,
                  iconColor: AppColor.darkGrey),
              SizedBox(width: 10),
              customText(
                user.location,
                style: TextStyle(color: AppColor.darkGrey),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              customIcon(context,
                  icon: AppIcon.calender,
                  size: 14,
                  istwitterIcon: true,
                  paddingIcon: 5,
                  iconColor: AppColor.darkGrey),
              SizedBox(width: 10),
              customText(
                getJoiningDate(user.createdAt),
                style: TextStyle(color:AppColor.darkGrey),
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
                '${user.getFollower()} ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              customText(
                'Followers',
                style: TextStyle(color: AppColor.darkGrey, fontSize: 17),
              ),
              SizedBox(width: 40),
              customText(
                '${user.getFollowing()} ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              customText(
                'Following',
                style: TextStyle(color: AppColor.darkGrey, fontSize: 17),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Divider(
          height: 0,
        )
      ],
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
