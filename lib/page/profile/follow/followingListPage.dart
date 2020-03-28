import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/page/common/usersListPage.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:provider/provider.dart';

class FollowingListPage extends StatefulWidget {
  FollowingListPage({Key key}) : super(key: key);

  @override
  _FollowingListPageState createState() => _FollowingListPageState();
}

class _FollowingListPageState extends State<FollowingListPage> {
  @override
  void initState() {
    var authstate = Provider.of<AuthState>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authstate.getFollowingUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return UsersListPage(
        pageTitle: 'Followers',
        userList: state.profileFollowingList,
        appBarIcon: AppIcon.follow,
        emptyScreenText:
            '${state?.profileUserModel?.userName ?? state.userModel.userName} isn\'t follow anyone',
        emptyScreenSubTileText: 'When they do they\'ll be listed here.');
  }
}
