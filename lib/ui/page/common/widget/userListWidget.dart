import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/ui/page/profile/profilePage.dart';
import 'package:flutter_twitter_clone/ui/page/profile/widgets/circular_image.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/rippleButton.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class UserListWidget extends StatelessWidget {
  final List<UserModel> list;
  final String? emptyScreenText;
  final String? emptyScreenSubTileText;
  const UserListWidget({
    Key? key,
    required this.list,
    this.emptyScreenText,
    this.emptyScreenSubTileText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    String myId = state.userModel!.key!;
    return ListView.separated(
      itemBuilder: (context, index) {
        return UserTile(
          user: list[index],
          myId: myId,
          onTrailingPressed: () {},
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 0,
        );
      },
      itemCount: list.length,
    );
    // : LinearProgressIndicator();
  }
}

class UserTile extends StatelessWidget {
  const UserTile(
      {Key? key,
      required this.user,
      required this.myId,
      required this.onTrailingPressed,
      this.trailing})
      : super(key: key);
  final UserModel user;
  final String myId;
  final VoidCallback onTrailingPressed;
  final Widget? trailing;

  /// Return empty string for default bio
  /// Max length of bio is 100
  String? getBio(String? bio) {
    if (bio != null && bio.isNotEmpty && bio != "Edit profile to update bio") {
      if (bio.length > 100) {
        bio = bio.substring(0, 100) + '...';
        return bio;
      } else {
        return bio;
      }
    }
    return null;
  }

  /// Check if user followerlist contain your or not
  /// If your id exist in follower list it mean you are following him
  bool isFollowing() {
    if (user.followersList != null &&
        user.followersList!.any((x) => x == myId)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFollow = isFollowing();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: TwitterColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.push(
                  context, ProfilePage.getRoute(profileId: user.userId!));
            },
            leading: RippleButton(
              onPressed: () {
                Navigator.push(
                    context, ProfilePage.getRoute(profileId: user.userId!));
              },
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child: CircularImage(path: user.profilePic, height: 55),
            ),
            title: Row(
              children: <Widget>[
                ConstrainedBox(
                  constraints:
                      BoxConstraints(minWidth: 0, maxWidth: context.width * .4),
                  child: TitleText(user.displayName!,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 3),
                user.isVerified!
                    ? customIcon(
                        context,
                        icon: AppIcon.blueTick,
                        istwitterIcon: true,
                        iconColor: AppColor.primary,
                        size: 13,
                        paddingIcon: 3,
                      )
                    : const SizedBox(width: 0),
              ],
            ),
            subtitle: Text(user.userName!),
            trailing: RippleButton(
              onPressed: onTrailingPressed,
              splashColor: TwitterColor.dodgetBlue_50.withAlpha(100),
              borderRadius: BorderRadius.circular(25),
              child: trailing ??
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isFollow ? 15 : 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isFollow
                          ? TwitterColor.dodgetBlue
                          : TwitterColor.white,
                      border:
                          Border.all(color: TwitterColor.dodgetBlue, width: 1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      isFollow ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: isFollow ? TwitterColor.white : Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ),
          ),
          getBio(user.bio) == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(left: 90),
                  child: Text(
                    getBio(user.bio)!,
                  ),
                )
        ],
      ),
    );
  }
}
