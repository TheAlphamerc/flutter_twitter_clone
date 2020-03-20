import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
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
      backgroundColor: TwitterColor.mystic,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Following',
        ),
        icon: AppIcon.follow,
      ),
      body: Consumer<AuthState>(
        builder: (context, state, child) {
          return UserListWidget(
            isFollowing: true,
            fetchingListbool: state.isbusy ?? false,
            list: state.profileFollowingList,
            emptyScreenText: '${state.profileUserModel.userName} isn\'t follow anyone',
            emptyScreenSubTileText : 'When they do they\'ll be listed here.'
          );
        },
      ),
    );
  }
}
