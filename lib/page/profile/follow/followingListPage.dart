import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';
import 'widget/userList.dart';

class FollowingListPage extends StatefulWidget {
  FollowingListPage({Key key}) : super(key: key);

  @override
  _FollowingListPageState createState() => _FollowingListPageState();
}

class _FollowingListPageState extends State<FollowingListPage> {
  @override
  void initState() {
    var authstate = Provider.of<AuthState>(context, listen: false);
    authstate.getFollowingUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var authstate = Provider.of<AuthState>(context);
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Following',
        ),
      ),
      body: UserListWidget(
        isFollowing: true,
        list: authstate.profileFollowingList,
        emptyScreenText: 'User is not following anyone.',
      ),
    );
  }
}
