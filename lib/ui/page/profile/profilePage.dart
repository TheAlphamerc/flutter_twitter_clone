import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/chats/chatState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/state/profile_state.dart';
import 'package:flutter_twitter_clone/ui/page/profile/EditProfilePage.dart';
import 'package:flutter_twitter_clone/ui/page/profile/follow/followerListPage.dart';
import 'package:flutter_twitter_clone/ui/page/profile/follow/followingListPage.dart';
import 'package:flutter_twitter_clone/ui/page/profile/profileImageView.dart';
import 'package:flutter_twitter_clone/ui/page/profile/qrCode/scanner.dart';
import 'package:flutter_twitter_clone/ui/page/profile/widgets/circular_image.dart';
import 'package:flutter_twitter_clone/ui/page/profile/widgets/tabPainter.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/cache_image.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customLoader.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/rippleButton.dart';
import 'package:flutter_twitter_clone/widgets/tweet/tweet.dart';
import 'package:flutter_twitter_clone/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:flutter_twitter_clone/widgets/url_text/customUrlText.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.profileId}) : super(key: key);

  final String profileId;
  static MaterialPageRoute getRoute({required String profileId}) {
    return MaterialPageRoute(
      builder: (_) => Provider(
        create: (_) => ProfileState(profileId),
        child: ChangeNotifierProvider(
          create: (BuildContext context) => ProfileState(profileId),
          builder: (_, child) => ProfilePage(
            profileId: profileId,
          ),
        ),
      ),
    );
  }

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isMyProfile = false;
  int pageIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var authState = Provider.of<ProfileState>(context, listen: false);

      isMyProfile = authState.isMyProfile;
    });
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  SliverAppBar getAppbar() {
    var authState = Provider.of<ProfileState>(context);
    return SliverAppBar(
      forceElevated: false,
      expandedHeight: 200,
      elevation: 0,
      stretch: true,
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        authState.isbusy
            ? const SizedBox.shrink()
            : PopupMenuButton<Choice>(
                onSelected: (d) {
                  if (d.title == "Share") {
                    shareProfile(context);
                  } else if (d.title == "QR code") {
                    Navigator.push(context,
                        ScanScreen.getRoute(authState.profileUserModel));
                  }
                },
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(
                        choice.title,
                        style: TextStyles.textStyle14.copyWith(
                            color: choice.isEnable
                                ? AppColor.secondary
                                : AppColor.lightGrey),
                      ),
                    );
                  }).toList();
                },
              ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const <StretchMode>[
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: authState.isbusy
            ? const SizedBox.shrink()
            : Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  SizedBox.expand(
                    child: Container(
                      padding: const EdgeInsets.only(top: 50),
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: 180,
                    padding: const EdgeInsets.only(top: 28),
                    child: CacheImage(
                      path: authState.profileUserModel.bannerImage ??
                          'https://pbs.twimg.com/profile_banners/457684585/1510495215/1500x500',
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 5),
                              shape: BoxShape.circle),
                          child: RippleButton(
                            child: CircularImage(
                              path: authState.profileUserModel.profilePic,
                              height: 80,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  ProfileImageView.getRoute(
                                      authState.profileUserModel.profilePic!));
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 90, right: 30),
                          child: Row(
                            children: <Widget>[
                              isMyProfile
                                  ? Container(height: 40)
                                  : RippleButton(
                                      splashColor: TwitterColor.dodgeBlue_50
                                          .withAlpha(100),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      onPressed: () {
                                        if (!isMyProfile) {
                                          final chatState =
                                              Provider.of<ChatState>(context,
                                                  listen: false);
                                          chatState.setChatUser =
                                              authState.profileUserModel;
                                          Navigator.pushNamed(
                                              context, '/ChatScreenPage');
                                        }
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        padding: const EdgeInsets.only(
                                            bottom: 5,
                                            top: 0,
                                            right: 0,
                                            left: 0),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: isMyProfile
                                                    ? Colors.black87
                                                        .withAlpha(180)
                                                    : Colors.blue,
                                                width: 1),
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          AppIcon.messageEmpty,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                              const SizedBox(width: 10),
                              RippleButton(
                                splashColor:
                                    TwitterColor.dodgeBlue_50.withAlpha(100),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(60)),
                                onPressed: () {
                                  if (isMyProfile) {
                                    Navigator.push(
                                        context, EditProfilePage.getRoute());
                                  } else {
                                    authState.followUser(
                                        removeFollower: isFollower());
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMyProfile
                                        ? TwitterColor.white
                                        : isFollower()
                                            ? TwitterColor.dodgeBlue
                                            : TwitterColor.white,
                                    border: Border.all(
                                        color: isMyProfile
                                            ? Colors.black87.withAlpha(180)
                                            : Colors.blue,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  /// If [isMyProfile] is true then Edit profile button will display
                                  // Otherwise Follow/Following button will be display
                                  child: Text(
                                    isMyProfile
                                        ? 'Edit Profile'
                                        : isFollower()
                                            ? 'Following'
                                            : 'Follow',
                                    style: TextStyle(
                                      color: isMyProfile
                                          ? Colors.black87.withAlpha(180)
                                          : isFollower()
                                              ? TwitterColor.white
                                              : Colors.blue,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
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
        isTwitterIcon: true,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }

  Widget _emptyBox() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  bool isFollower() {
    var authState = Provider.of<ProfileState>(context, listen: false);
    if (authState.profileUserModel.followersList != null &&
        authState.profileUserModel.followersList!.isNotEmpty) {
      return (authState.profileUserModel.followersList!
          .any((x) => x == authState.userId));
    } else {
      return false;
    }
  }

  /// This method called when user pressed back button
  /// When profile page is about to close
  /// Maintain minimum user's profile in profile page list
  Future<bool> _onWillPop() async {
    return true;
  }

  late TabController _tabController;

  void shareProfile(BuildContext context) async {
    var authState = context.read<ProfileState>();
    var user = authState.profileUserModel;
    Utility.createLinkAndShare(
      context,
      "profilePage/${widget.profileId}/",
      socialMetaTagParameters: SocialMetaTagParameters(
        description: !user.bio!.contains("Edit profile")
            ? user.bio
            : "Checkout ${user.displayName}'s profile on Fwitter app",
        title: "${user.displayName} is on Fwitter app",
        imageUrl: Uri.parse(user.profilePic!),
      ),
    );
  }

  @override
  build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    var authState = Provider.of<ProfileState>(context);
    List<FeedModel>? list;
    String id = widget.profileId;

    /// Filter user's tweet among all tweets available in home page tweets list
    if (state.feedList != null && state.feedList!.isNotEmpty) {
      list = state.feedList!.where((x) => x.userId == id).toList();
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: !isMyProfile ? null : _floatingActionButton(),
        backgroundColor: TwitterColor.mystic,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
            return <Widget>[
              getAppbar(),
              authState.isbusy
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        child: authState.isbusy
                            ? const SizedBox.shrink()
                            : UserNameRowWidget(
                                user: authState.profileUserModel,
                                isMyProfile: isMyProfile,
                              ),
                      ),
                    ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      color: TwitterColor.white,
                      child: TabBar(
                        indicator: TabIndicator(),
                        controller: _tabController,
                        tabs: const <Widget>[
                          Text("Tweets"),
                          Text("Tweets & replies"),
                          Text("Media")
                        ],
                      ),
                    )
                  ],
                ),
              )
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              /// Display all independent tweets list
              _tweetList(context, authState, list, false, false),

              /// Display all reply tweet list
              _tweetList(context, authState, list, true, false),

              /// Display all reply and comments tweet list
              _tweetList(context, authState, list, false, true)
            ],
          ),
        ),
      ),
    );
  }

  Widget _tweetList(BuildContext context, ProfileState authState,
      List<FeedModel>? tweetsList, bool isReply, bool isMedia) {
    List<FeedModel>? list;

    /// If user hasn't tweeted yet
    if (tweetsList == null) {
      // cprint('No Tweet available');
    } else if (isMedia) {
      /// Display all Tweets with media file

      list = tweetsList.where((x) => x.imagePath != null).toList();
    } else if (!isReply) {
      /// Display all independent Tweets
      /// No comments Tweet will display

      list = tweetsList
          .where((x) => x.parentkey == null || x.childRetwetkey != null)
          .toList();
    } else {
      /// Display all reply Tweets
      /// No independent tweet will display
      list = tweetsList
          .where((x) => x.parentkey != null && x.childRetwetkey == null)
          .toList();
    }

    /// if [authState.isbusy] is true then an loading indicator will be displayed on screen.
    return authState.isbusy
        ? SizedBox(
            height: context.height - 180,
            child: const CustomScreenLoader(
              height: double.infinity,
              width: double.infinity,
              backgroundColor: Colors.white,
            ),
          )

        /// if tweet list is empty or null then need to show user a message
        : list == null || list.isEmpty
            ? Container(
                padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
                child: NotifyText(
                  title: isMyProfile
                      ? 'You haven\'t ${isReply ? 'reply to any Tweet' : isMedia ? 'post any media Tweet yet' : 'post any Tweet yet'}'
                      : '${authState.profileUserModel.userName} hasn\'t ${isReply ? 'reply to any Tweet' : isMedia ? 'post any media Tweet yet' : 'post any Tweet yet'}',
                  subTitle: isMyProfile
                      ? 'Tap tweet button to add new'
                      : 'Once he\'ll do, they will be shown up here',
                ),
              )

            /// If tweets available then tweet list will displayed
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 0),
                itemCount: list.length,
                itemBuilder: (context, index) => Container(
                  color: TwitterColor.white,
                  child: Tweet(
                    model: list![index],
                    isDisplayOnProfile: true,
                    trailing: TweetBottomSheet().tweetOptionIcon(
                      context,
                      model: list[index],
                      type: TweetType.Tweet,
                      scaffoldKey: scaffoldKey,
                    ),
                    scaffoldKey: scaffoldKey,
                  ),
                ),
              );
  }
}

class UserNameRowWidget extends StatelessWidget {
  const UserNameRowWidget({
    Key? key,
    required this.user,
    required this.isMyProfile,
  }) : super(key: key);

  final bool isMyProfile;
  final UserModel user;

  String getBio(String bio) {
    if (isMyProfile) {
      return bio;
    } else if (bio == "Edit profile to update bio") {
      return "No bio available";
    } else {
      return bio;
    }
  }

  Widget _textButton(
    BuildContext context,
    String count,
    String text,
    Function onPressed,
  ) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Row(
        children: <Widget>[
          customText(
            '$count ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          customText(
            text,
            style: const TextStyle(color: AppColor.darkGrey, fontSize: 17),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(
            children: <Widget>[
              UrlText(
                text: user.displayName!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                width: 3,
              ),
              user.isVerified!
                  ? customIcon(context,
                      icon: AppIcon.blueTick,
                      isTwitterIcon: true,
                      iconColor: AppColor.primary,
                      size: 13,
                      paddingIcon: 3)
                  : const SizedBox(width: 0),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: customText(
            '${user.userName}',
            style: TextStyles.subtitleStyle.copyWith(fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: customText(
            getBio(user.bio!),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              customIcon(context,
                  icon: AppIcon.locationPin,
                  size: 14,
                  isTwitterIcon: true,
                  paddingIcon: 5,
                  iconColor: AppColor.darkGrey),
              const SizedBox(width: 10),
              Expanded(
                child: customText(
                  user.location,
                  style: const TextStyle(color: AppColor.darkGrey),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              customIcon(context,
                  icon: AppIcon.calender,
                  size: 14,
                  isTwitterIcon: true,
                  paddingIcon: 5,
                  iconColor: AppColor.darkGrey),
              const SizedBox(width: 10),
              customText(
                Utility.getJoiningDate(user.createdAt),
                style: const TextStyle(color: AppColor.darkGrey),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 10,
                height: 30,
              ),
              _textButton(context, user.getFollower, ' Followers', () {
                var state = context.read<ProfileState>();
                Navigator.push(
                  context,
                  FollowerListPage.getRoute(
                    profile: state.profileUserModel,
                    userList: state.profileUserModel.followersList!,
                  ),
                );
              }),
              const SizedBox(width: 40),
              _textButton(context, user.getFollowing, ' Following', () {
                var state = context.read<ProfileState>();
                Navigator.push(
                  context,
                  FollowingListPage.getRoute(
                    profile: state.profileUserModel,
                    userList: state.profileUserModel.followingList!,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class Choice {
  const Choice(
      {required this.title, required this.icon, this.isEnable = false});
  final bool isEnable;
  final IconData icon;
  final String title;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'Share', icon: Icons.directions_car, isEnable: true),
  Choice(title: 'QR code', icon: Icons.directions_railway, isEnable: true),
  Choice(title: 'Draft', icon: Icons.directions_bike),
  Choice(title: 'View Lists', icon: Icons.directions_boat),
  Choice(title: 'View Moments', icon: Icons.directions_bus),
];
