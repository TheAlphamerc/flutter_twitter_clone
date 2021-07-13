import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/ui/page/feed/feedPostDetail.dart';
import 'package:flutter_twitter_clone/widgets/tweet/tweet.dart';
import 'package:flutter_twitter_clone/widgets/tweet/widgets/unavailableTweet.dart';
import 'package:provider/provider.dart';

class ParentTweetWidget extends StatelessWidget {
  ParentTweetWidget(
      {Key key,
      this.childRetwetkey,
      this.type,
      this.isImageAvailable,
      this.trailing,
      @required this.onTweetAction,
      @required this.fetchTweet,
      @required this.onRetweet,
      @required this.onTweetUpdate})
      : super(key: key);

  final String childRetwetkey;
  final TweetType type;
  final Widget trailing;
  final bool isImageAvailable;
  final Future<FeedModel> Function(String key) fetchTweet;
  final void Function(FeedModel) onRetweet;
  final void Function(FeedModel) onTweetUpdate;
  final Function(TweetAction action, FeedModel model) onTweetAction;

  void onTweetPressed(BuildContext context, FeedModel model) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    // feedstate.getpostDetailFromDatabase(null, model: model);
    Navigator.push(context, FeedPostDetail.getRoute(model.key));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchTweet(childRetwetkey),
      builder: (context, AsyncSnapshot<FeedModel> snapshot) {
        if (snapshot.hasData) {
          return Tweet(
            model: snapshot.data,
            type: TweetType.ParentTweet,
            trailing: trailing,
            onTweetAction: onTweetAction,
            fetchTweet: (key) {
              return fetchTweet(childRetwetkey);
            },
            onRetweet: onRetweet,
            onTweetUpdate: onTweetUpdate,
          );
        }
        if ((snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) &&
            !snapshot.hasData) {
          return UnavailableTweet(
            snapshot: snapshot,
            type: type,
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
