import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/customRoute.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/shared_prefrence_helper.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/state/tweetDetailState.dart';
import 'package:flutter_twitter_clone/ui/page/common/locator.dart';
import 'package:flutter_twitter_clone/ui/page/feed/composeTweet/composeTweet.dart';
import 'package:flutter_twitter_clone/ui/page/feed/imageViewPage.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/tweet/tweet.dart';
import 'package:flutter_twitter_clone/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';

class FeedPostDetail extends StatefulWidget {
  FeedPostDetail({Key key, this.postId}) : super(key: key);
  final String postId;

  static Route<T> getRoute<T>(String postId) {
    return SlideLeftRoute<T>(
      builder: (BuildContext context) => Provider(
        create: (_) => TweetDetailState(),
        builder: (BuildContext context, Widget child) => child,
        child: ChangeNotifierProvider(
          create: (_) => TweetDetailState(postId: postId),
          child: FeedPostDetail(postId: postId),
        ),
      ),
    );
  }

  _FeedPostDetailState createState() => _FeedPostDetailState();
}

class _FeedPostDetailState extends State<FeedPostDetail> {
  String postId;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    postId = widget.postId;
    // var state = Provider.of<TweetDetailState>(context, listen: false);
    // state.getpostDetailFromDatabase(postId);
    super.initState();
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          ComposeTweetPage.getRoute(
              isReplyTweet: true,
              tweetToReplyModel: context.read<TweetDetailState>().tweet),
        );
        // var state = Provider.of<TweetDetailState>(context, listen: false);
        // state.setTweetToReply = state.tweet;
        // Navigator.of(context).pushNamed('/ComposeTweetPage/' + postId);
      },
      child: Icon(Icons.add),
    );
  }

  Widget _commentRow(FeedModel model) {
    return Tweet(
      model: model,
      type: TweetType.Reply,
      trailing: TweetBottomSheet().tweetOptionIcon(context,
          scaffoldKey: scaffoldKey,
          model: model,
          type: TweetType.Reply,
          onTweeDelete: null),
      onTweetAction: (action, model) {
        switch (action) {
          case TweetAction.Like:
            {
              var user = getIt<SharedPreferenceHelper>().user;
              context.read<TweetDetailState>().handleTweetLike(model, user.key);
            }
            break;
          default:
            cprint("Handle $action");
        }
      },
      fetchTweet: (key) {
        return context.read<TweetDetailState>().getpostDetailFromDatabase(key);
      },
      onTweetUpdate: (model) {
        context.read<TweetDetailState>().updateTweet(model);
      },
      onRetweet: (model) {
        context.read<TweetDetailState>().createPost(model);
      },
    );
  }

  Widget _tweetDetail(FeedModel model) {
    if (model == null) {
      return SizedBox.shrink();
    }
    return Tweet(
      model: model,
      type: TweetType.Detail,
      trailing: TweetBottomSheet().tweetOptionIcon(
        context,
        scaffoldKey: scaffoldKey,
        model: model,
        type: TweetType.Detail,
        onTweeDelete: (String tweetId, TweetType type, {String parentkey}) {
          context
              .read<TweetDetailState>()
              .deleteTweet(tweetId, type, parentkey: parentkey);
        },
      ),
      onTweetAction: (action, model) {
        switch (action) {
          case TweetAction.Like:
            {
              var user = getIt<SharedPreferenceHelper>().user;
              context.read<TweetDetailState>().handleTweetLike(model, user.key);
            }
            break;
          default:
            cprint("Handle $action");
        }
      },
      fetchTweet: (key) {
        return context.read<TweetDetailState>().getpostDetailFromDatabase(key);
      },
      onTweetUpdate: (model) {
        context.read<TweetDetailState>().updateTweet(model);
      },
      onRetweet: (model) {
        context.read<TweetDetailState>().createPost(model);
      },
    );
  }

  void addLikeToComment(String commentId) {
    var state = Provider.of<TweetDetailState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addLikeToTweet(state.tweet, authState.userId);
  }

  void openImage() async {
    var model = context.read<TweetDetailState>().tweet;
    Navigator.push(
      context,
      ImageViewPage.getRoute(model: model),
    );
  }

  void deleteTweet(TweetType type, String tweetId, {String parentkey}) {
    var state = Provider.of<TweetDetailState>(context, listen: false);
    state.deleteTweet(tweetId, type, parentkey: parentkey);
    Navigator.of(context).pop();
    if (type == TweetType.Detail) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<TweetDetailState>();
    return WillPopScope(
      onWillPop: () async {
        // Provider.of<TweetDetailState>(context, listen: false)
        //     .removeLastTweetDetail(postId);
        return Future.value(true);
      },
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: _floatingActionButton(),
        backgroundColor: Theme.of(context).backgroundColor,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              title: customTitleText('Thread'),
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
              delegate: SliverChildListDelegate(
                [
                  _tweetDetail(state.tweet),
                  Container(
                    height: 6,
                    width: context.width,
                    color: TwitterColor.mystic,
                  )
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                state.commentlist == null || state.commentlist.length == 0
                    // state.commentlist[postId] == null
                    ? [
                        Container(
                          child: Center(
                              //  child: Text('No comments'),
                              ),
                        )
                      ]
                    : state.commentlist.map((x) => _commentRow(x)).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
