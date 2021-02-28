import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/ui/page/settings/widgets/settingsRowWidget.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class TrendsPage extends StatelessWidget {
  String sortBy = "";

  TrendsPage({Key key}) : super(key: key);

  void openBottomSheet(
      BuildContext context, double height, Widget child) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: TwitterColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: child,
        );
      },
    );
  }

  void openUserSortSettings(BuildContext context) {
    openBottomSheet(
      context,
      340,
      Column(
        children: <Widget>[
          SizedBox(height: 5),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: TwitterColor.paleSky50,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TitleText('Sort user list'),
          ),
          Divider(height: 0),
          _row(context, "Verified user first", SortUser.Verified),
          Divider(height: 0),
          _row(context, "alphabetically", SortUser.Alphabetically),
          Divider(height: 0),
          _row(context, "Newest user first", SortUser.Newest),
          Divider(height: 0),
          _row(context, "Oldest user first", SortUser.Oldest),
          Divider(height: 0),
          _row(context, "UserModelModel with max follower",
              SortUser.MaxFollower),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String text, SortUser sortBy) {
    final state = Provider.of<SearchState>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: RadioListTile<SortUser>(
        value: sortBy,
        activeColor: TwitterColor.dodgetBlue,
        groupValue: state.sortBy,
        onChanged: (val) {
          state.updateUserSortPrefrence = val;
          Navigator.pop(context);
        },
        title: Text(text, style: TextStyles.subtitleStyle),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      sortBy = state.selectedFilter;
    });
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Trends',
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          SettingRowWidget(
            "Search Filter",
            subtitle: sortBy,
            onPressed: () {
              openUserSortSettings(context);
            },
            showDivider: false,
          ),
          SettingRowWidget(
            "Trends location",
            navigateTo: null,
            subtitle: 'New York',
            showDivider: false,
          ),
          SettingRowWidget(
            null,
            subtitle:
                'You can see what\'s trending in a specfic location by selecting which location appears in your Trending tab.',
            navigateTo: null,
            showDivider: false,
            vPadding: 12,
          ),
        ],
      ),
    );
  }
}
