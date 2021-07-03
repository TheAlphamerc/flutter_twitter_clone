import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/model/notificationModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/ui/page/profile/profilePage.dart';
import 'package:flutter_twitter_clone/ui/page/profile/widgets/circular_image.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/url_text/customUrlText.dart';

class FollowNotificationTile extends StatelessWidget {
  final NotificationModel model;
  const FollowNotificationTile({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: TwitterColor.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 26),
          child: Column(
            children: [
              Row(
                children: [
                  customIcon(context, icon: AppIcon.profile, isEnable: true),
                  SizedBox(width: 10),
                  Text(
                    model.user.displayName,
                    style: TextStyles.titleStyle.copyWith(fontSize: 14),
                  ),
                  Text(" Followed you", style: TextStyles.subtitleStyle),
                ],
              ),
              SizedBox(width: 10),
              _UserCard(user: model.user)
            ],
          ),
        ),
        Divider(height: 0, thickness: .6)
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  const _UserCard({Key key, this.user}) : super(key: key);
  String getBio(String bio) {
    if (bio == "Edit profile to update bio") {
      return "No bio available";
    } else {
      return bio;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 30, top: 10, bottom: 8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.extraLightGrey, width: .5),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularImage(path: user.profilePic, height: 40),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
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
                    SizedBox(width: 3),
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
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 9),
                child: customText(
                  '${user.userName}',
                  style: TextStyles.subtitleStyle.copyWith(fontSize: 13),
                ),
              ),
              if (getBio(user.bio).isNotEmpty) ...[
                // SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: customText(
                    getBio(user.bio),
                  ),
                ),
              ],
            ],
          ),
        ).ripple(() {
          Navigator.push(context, ProfilePage.getRoute(profileId: user.userId));
        }, borderRadius: BorderRadius.circular(15)));
  }
}
