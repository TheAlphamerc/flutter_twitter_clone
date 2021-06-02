import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/ui/page/common/usersListPage.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class FollowingListPage extends StatelessWidget {
   FollowingListPage({Key key, this.userList, this.profile}) : super(key: key);
  final List<String> userList;
  final UserModel profile;

  static MaterialPageRoute getRoute(
      {List<String> userList, UserModel profile}) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return FollowingListPage(
          profile: profile,
          userList: userList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return UsersListPage(
        pageTitle: 'Following',
        userIdsList: state.profileUserModel.followingList,
        appBarIcon: AppIcon.follow,
        emptyScreenText:
            '${state?.profileUserModel?.userName ?? state.userModel.userName} isn\'t follow anyone',
        emptyScreenSubTileText: 'When they do they\'ll be listed here.');
  }
}
