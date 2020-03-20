import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/page/profile/follow/widget/userList.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class FollowerListPage extends StatelessWidget {
  FollowerListPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // var authstate = Provider.of<AuthState>(context);
    return Scaffold(
      backgroundColor: TwitterColor.mystic,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Followers',
        ),
        icon: AppIcon.follow,
      ),
      body: Consumer<AuthState>(
        builder: (context, state, child) {
          return UserListWidget(
            fetchingListbool: state.isbusy ?? false,
            list: state.profileUserModel?.followersList,
            emptyScreenText: '${state.profileUserModel.userName} doesn\'t have any followers',
            emptyScreenSubTileText: 'When someone follow them, they\'ll be listed here.',
          );
        },
      ),
    );
  }
}
