import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/ui/page/common/usersListPage.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';

class FollowerListPage extends StatelessWidget {
  FollowerListPage({Key key, this.userList, this.profile}) : super(key: key);
  final List<String> userList;
  final UserModel profile;

  static MaterialPageRoute getRoute(
      {List<String> userList, UserModel profile}) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return FollowerListPage(
          profile: profile,
          userList: userList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return UsersListPage(
      pageTitle: 'Followers',
      userIdsList: userList,
      appBarIcon: AppIcon.follow,
      emptyScreenText: '${profile?.userName} doesn\'t have any followers',
      emptyScreenSubTileText:
          'When someone follow them, they\'ll be listed here.',
    );
  }
}
