import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';
import 'package:flutter_twitter_clone/ui/page/common/widget/userListWidget.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class UsersListPage extends StatelessWidget {
  const UsersListPage({
    Key? key,
    this.pageTitle = "",
    // this.appBarIcon,
    required this.emptyScreenText,
    required this.emptyScreenSubTileText,
    this.userIdsList,
    this.onFollowPressed,
    this.isFollowing,
  }) : super(key: key);

  final String pageTitle;
  final String emptyScreenText;
  final String emptyScreenSubTileText;
  final bool Function(UserModel user)? isFollowing;
  final List<String>? userIdsList;
  final Function(UserModel user)? onFollowPressed;

  @override
  Widget build(BuildContext context) {
    List<UserModel>? userList;
    return Scaffold(
      backgroundColor: TwitterColor.mystic,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          pageTitle, /*icon: appBarIcon*/
        ),
      ),
      body: Consumer<SearchState>(
        builder: (context, state, child) {
          if (userIdsList != null && userIdsList!.isNotEmpty) {
            userList = state.getuserDetail(userIdsList!);
          }
          return userList != null && userList!.isNotEmpty
              ? UserListWidget(
                  list: userList!,
                  emptyScreenText: emptyScreenText,
                  emptyScreenSubTileText: emptyScreenSubTileText,
                  onFollowPressed: onFollowPressed,
                  isFollowing: isFollowing,
                )
              : Container(
                  width: context.width,
                  padding: const EdgeInsets.only(top: 0, left: 30, right: 30),
                  child: NotifyText(
                    title: emptyScreenText,
                    subTitle: emptyScreenSubTileText,
                  ),
                );
        },
      ),
    );
  }
}
