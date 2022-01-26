import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/chats/suggestionUserState.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';
import 'package:flutter_twitter_clone/ui/page/common/widget/userListWidget.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customFlatButton.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customLoader.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class SuggestedUsers extends StatefulWidget {
  const SuggestedUsers({Key? key, this.appbar}) : super(key: key);
  final SliverAppBar? appbar;

  @override
  State<SuggestedUsers> createState() => _SuggestedUsersState();
}

class _SuggestedUsersState extends State<SuggestedUsers> {
  late ValueNotifier<bool> isLoading;
  @override
  void initState() {
    isLoading = ValueNotifier<bool>(false);
    super.initState();
  }

  @override
  void dispose() {
    isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<SearchState>();
    final authstate = context.watch<AuthState>();
    final state = context.watch<SuggestionsState>();
    state.setUserlist(searchState.userlist);

    final isFollowListAvailable = !searchState.isBusy &&
        searchState.userlist != null &&
        searchState.userlist!.isNotEmpty;

    return Scaffold(
      bottomNavigationBar: !isFollowListAvailable
          ? null
          : BottomAppBar(
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: state.selectedusersCount >= 5
                          ? SizedBox()
                          : Text(
                              '${5 - state.selectedusersCount} more to follow',
                              style: TextStyles.titleStyle,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CustomFlatButton(
                        onPressed: state.selectedusersCount < 5
                            ? null
                            : () async {
                                isLoading.value = true;
                                await state.followUsers();
                                isLoading.value = false;
                              },
                        label: state.selectedusersCount < 5
                            ? '${5 - state.selectedusersCount} more to follow'
                            : 'Follow ${state.selectedusersCount}',
                        isWraped: true,
                        borderRadius: 50,
                        labelStyle: TextStyles.onPrimaryTitleText,
                        color: state.selectedusersCount < 5
                            ? Colors.grey[350]
                            : TwitterColor.dodgetBlue,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: SafeArea(
        child: Container(
          child: searchState.isBusy
              ? SizedBox(
                  height: context.height,
                  child: CustomScreenLoader(
                    height: double.infinity,
                    width: context.width,
                    backgroundColor: Colors.white,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title:
                          Image.asset('assets/images/icon-480.png', height: 40),
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                      centerTitle: true,
                      pinned: true,
                      primary: true,
                      elevation: 2,
                      expandedHeight:
                          kToolbarHeight + (isFollowListAvailable ? 180 : 100),
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const <StretchMode>[
                          StretchMode.zoomBackground,
                          StretchMode.blurBackground
                        ],
                        background: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: kToolbarHeight),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleText('Suggestions for you to follow'),
                                  SizedBox(height: 8),
                                  Text(
                                    'When you follow someone, you\'ll see their Tweets in your Home Timeline',
                                    style: TextStyles.textStyle14,
                                  ),
                                ],
                              ),
                            ),
                            if (isFollowListAvailable) ...[
                              Divider(),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TitleText('You may be Interested In'),
                                    IconButton(
                                      onPressed: () {
                                        state.toggleAllSelections();
                                      },
                                      icon: state.selectedusersCount ==
                                              state.userlist!.length
                                          ? Icon(
                                              Icons.check_circle,
                                              color: TwitterColor.dodgetBlue,
                                            )
                                          : Icon(
                                              Icons.add_circle_outline_outlined,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    !isFollowListAvailable
                        ? SliverFillRemaining(
                            child: Column(
                              children: [
                                SizedBox(height: 100),
                                NotifyText(
                                    subTitle: 'No user available to follow'),
                                TextButton(
                                  onPressed: () {
                                    state.displaySuggestions = false;
                                  },
                                  child: Text('Skip'),
                                ),
                              ],
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final user = state.userlist != null
                                    ? state.userlist![index]
                                    : null;

                                if (user == null) {
                                  return SizedBox();
                                }
                                return UserTile(
                                  user: user,
                                  myId: authstate.userId,
                                  onTrailingPressed: () {
                                    state.toggleUserSelection(user);
                                  },
                                  trailing: IconButton(
                                    onPressed: null,
                                    icon: state.isSelected(user)
                                        ? Icon(
                                            Icons.check_circle,
                                            color: TwitterColor.dodgetBlue,
                                          )
                                        : Icon(
                                            Icons.add_circle_outline_outlined),
                                  ),
                                );
                              },
                              childCount: state.userlist?.length ?? 0,
                            ),
                          )
                  ],
                ),
        ),
      ),
    );
  }
}
