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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authstate.getFollowingUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Following',
        ),
      ),
      body: Consumer<AuthState>(
        builder: (context, state, child) {
          return UserListWidget(
            isFollowing: true,
            fetchingListbool: state.isbusy ?? false,
            list: state.profileFollowingList,
            emptyScreenText: 'No one follow user yet',
          );
        },
      ),
    );
  }
}
