import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/tweet.dart';
import 'package:provider/provider.dart';

import 'widgets/tweetBottomSheet.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key key, this.scaffoldKey}) : super(key: key);
  _FeedPageState createState() => _FeedPageState();

  final GlobalKey<ScaffoldState> scaffoldKey;
}

class _FeedPageState extends State<FeedPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage');
      },
      child: customIcon(
        context,
        icon: AppIcon.fabTweet,
        istwitterIcon: true,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }
 Widget _getUserAvatar(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: customInkWell(
        context: context,
        onPressed: () {
          widget.scaffoldKey.currentState.openDrawer();
        },
        child:
            customImage(context, authState.userModel?.profilePic, height: 30),
      ),
    );
  }
  Widget _body() {
    var state = Provider.of<FeedState>(context);
    if (state.isBusy && state.feedlist == null) {
      return loader();
    } else if (!state.isBusy && state.feedlist == null) {
      return EmptyListWidget(
        title: 'No Feed',
        subTitle: 'Seems like no feed available yet',
        packageImage: PackageImage.Image_2,
      );
    } else {
      return CustomScrollView(
        // physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          //  ListView.builder(
          //   physics: BouncingScrollPhysics(),
          //   itemCount: state.feedlist.length,
          //   itemBuilder: (context, index) => Tweet(
          //     model: state.feedlist[index],
          //     trailing: TweetBottomSheet().tweetOptionIcon(context,state.feedlist[index],TweetType.Tweet),
          //     ),
          // ),
           SliverAppBar(
              floating: true,
              elevation: 0,
              leading: _getUserAvatar(context),
              title: customTitleText('Home'),
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              backgroundColor: Theme.of(context).appBarTheme.color,
              bottom: PreferredSize(
                child: Container(
                  color: Colors.grey.shade200,
                  height: 1.0,
                ),
                preferredSize: Size.fromHeight(0.0),
              ),
            ),
          SliverList(
            delegate:SliverChildListDelegate(
              state.feedlist.map((model){
                return Tweet(
                 model: model,
                 trailing: TweetBottomSheet().tweetOptionIcon(context,model,TweetType.Tweet),
                 );
              }).toList()
            )
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingActionButton(),
      backgroundColor: Theme.of(context).backgroundColor,
      // appBar: CustomAppBar(
      //   scaffoldKey: widget.scaffoldKey,
      //   title: customTitleText('Home'),
      // ),
      body: SafeArea(
        child: Container(
        height: fullHeight(context),
        width: fullWidth(context),
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            var state = Provider.of<FeedState>(context);
            state.getDataFromDatabase();
            return Future.value(true);
          },
          child: _body(),
        ),
      ),
      )
    );
  }
}
