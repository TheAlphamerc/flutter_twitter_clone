import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/ui/page/feed/composeTweet/composeTweet.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/share_widget.dart';
import 'package:flutter_twitter_clone/widgets/tweet/tweet.dart';
import 'package:provider/provider.dart';

class TweetBottomSheet {
  Widget tweetOptionIcon(
    BuildContext context, {
    FeedModel model,
    TweetType type,
    GlobalKey<ScaffoldState> scaffoldKey,
    @required
        void Function(String tweetId, TweetType type, {String parentkey})
            onTweeDelete,
  }) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: customIcon(context,
          icon: AppIcon.arrowDown,
          istwitterIcon: true,
          iconColor: AppColor.lightGrey),
    ).ripple(
      () {
        _openbottomSheet(context,
            type: type,
            model: model,
            scaffoldKey: scaffoldKey,
            onTweeDelete: onTweeDelete);
      },
      borderRadius: BorderRadius.circular(20),
    );
  }

  void _openbottomSheet(
    BuildContext context, {
    TweetType type,
    FeedModel model,
    GlobalKey<ScaffoldState> scaffoldKey,
    @required
        void Function(String tweetId, TweetType type, {String parentkey})
            onTweeDelete,
  }) async {
    var authState = Provider.of<AuthState>(context, listen: false);
    bool isMyTweet = authState.userId == model.userId;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: context.height *
                (type == TweetType.Tweet
                    ? (isMyTweet ? .25 : .44)
                    : (isMyTweet ? .38 : .52)),
            width: context.width,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: type == TweetType.Tweet
                ? _tweetOptions(
                    context,
                    scaffoldKey: scaffoldKey,
                    isMyTweet: isMyTweet,
                    model: model,
                    type: type,
                    onTweeDelete: onTweeDelete,
                  )
                : _tweetDetailOptions(context,
                    scaffoldKey: scaffoldKey,
                    isMyTweet: isMyTweet,
                    model: model,
                    type: type,
                    onTweeDelete: onTweeDelete));
      },
    );
  }

  Widget _tweetDetailOptions(
    BuildContext context, {
    bool isMyTweet,
    FeedModel model,
    TweetType type,
    GlobalKey<ScaffoldState> scaffoldKey,
    @required
        Function(String tweetId, TweetType type, {String parentkey})
            onTweeDelete,
  }) {
    return Column(
      children: <Widget>[
        Container(
          width: context.width * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(context, AppIcon.link,
            text: 'Copy link to tweet', isEnable: true, onPressed: () async {
          Navigator.pop(context);
          var uri = await Utility.createLinkToShare(
            context,
            "tweet/${model.key}",
            socialMetaTagParameters: SocialMetaTagParameters(
                description: model.description ??
                    "${model.user.displayName} posted a tweet on Fwitter.",
                title: "Tweet on Fwitter app",
                imageUrl: Uri.parse(
                    "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
          );

          Utility.copyToClipBoard(
              scaffoldKey: scaffoldKey,
              text: uri.toString(),
              message: "Tweet link copy to clipboard");
        }),
        isMyTweet
            ? _widgetBottomSheetRow(
                context,
                AppIcon.delete,
                text: 'Delete Tweet',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Delete"),
                      content: Text('Do you want to delete this Tweet?'),
                      actions: [
                        // ignore: deprecated_member_use
                        FlatButton(
                          textColor: Colors.black,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        // ignore: deprecated_member_use
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              TwitterColor.dodgetBlue,
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              TwitterColor.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteTweet(
                              context,
                              type,
                              model.key,
                              parentkey: model.parentkey,
                              onTweeDelete: onTweeDelete,
                            );
                          },
                          child: Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                },
                isEnable: true,
              )
            : Container(),
        isMyTweet
            ? _widgetBottomSheetRow(
                context,
                AppIcon.unFollow,
                text: 'Pin to profile',
              )
            : _widgetBottomSheetRow(
                context,
                AppIcon.unFollow,
                text: 'Unfollow ${model.user.userName}',
              ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.mute,
                text: 'Mute ${model.user.userName}',
              ),
        _widgetBottomSheetRow(
          context,
          AppIcon.mute,
          text: 'Mute this convertion',
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.viewHidden,
          text: 'View hidden replies',
        ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.block,
                text: 'Block ${model.user.userName}',
              ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.report,
                text: 'Report Tweet',
              ),
      ],
    );
  }

  Widget _tweetOptions(
    BuildContext context, {
    bool isMyTweet,
    FeedModel model,
    TweetType type,
    GlobalKey<ScaffoldState> scaffoldKey,
    @required
        void Function(String tweetId, TweetType type, {String parentkey})
            onTweeDelete,
  }) {
    return Column(
      children: <Widget>[
        Container(
          width: context.width * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(context, AppIcon.link,
            text: 'Copy link to tweet', isEnable: true, onPressed: () async {
          var uri = await Utility.createLinkToShare(
            context,
            "tweet/${model.key}",
            socialMetaTagParameters: SocialMetaTagParameters(
                description: model.description ??
                    "${model.user.displayName} posted a tweet on Fwitter.",
                title: "Tweet on Fwitter app",
                imageUrl: Uri.parse(
                    "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw")),
          );

          Navigator.pop(context);
          Utility.copyToClipBoard(
              scaffoldKey: scaffoldKey,
              text: uri.toString(),
              message: "Tweet link copy to clipboard");
        }),
        isMyTweet
            ? _widgetBottomSheetRow(
                context,
                AppIcon.delete,
                text: 'Delete Tweet',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Delete"),
                      content: Text('Do you want to delete this Tweet?'),
                      actions: [
                        // ignore: deprecated_member_use
                        FlatButton(
                          textColor: Colors.black,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        // ignore: deprecated_member_use
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              TwitterColor.dodgetBlue,
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              TwitterColor.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteTweet(
                              context,
                              type,
                              model.key,
                              parentkey: model.parentkey,
                              onTweeDelete: onTweeDelete,
                            );
                          },
                          child: Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                },
                isEnable: true,
              )
            : Container(),
        isMyTweet
            ? _widgetBottomSheetRow(
                context,
                AppIcon.thumbpinFill,
                text: 'Pin to profile',
              )
            : _widgetBottomSheetRow(
                context,
                AppIcon.sadFace,
                text: 'Not interested in this',
              ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.unFollow,
                text: 'Unfollow ${model.user.userName}',
              ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.mute,
                text: 'Mute ${model.user.userName}',
              ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.block,
                text: 'Block ${model.user.userName}',
              ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.report,
                text: 'Report Tweet',
              ),
      ],
    );
  }

  Widget _widgetBottomSheetRow(BuildContext context, IconData icon,
      {String text, Function onPressed, bool isEnable = false}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            customIcon(
              context,
              icon: icon,
              istwitterIcon: true,
              size: 25,
              paddingIcon: 8,
              iconColor:
                  onPressed != null ? AppColor.darkGrey : AppColor.lightGrey,
            ),
            SizedBox(
              width: 15,
            ),
            customText(
              text,
              context: context,
              style: TextStyle(
                color: isEnable ? AppColor.secondary : AppColor.lightGrey,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ).ripple(() {
        if (onPressed != null)
          onPressed();
        else {
          Navigator.pop(context);
        }
      }),
    );
  }

  void _deleteTweet(
    BuildContext context,
    TweetType type,
    String tweetId, {
    String parentkey,
    @required
        Function(String tweetId, TweetType type, {String parentkey})
            onTweeDelete,
  }) {
    // var state = Provider.of<FeedState>(context, listen: false);
    onTweeDelete(tweetId, type, parentkey: parentkey);
    // CLose bottom sheet
    Navigator.of(context).pop();
    if (type == TweetType.Detail) {
      // Close Tweet detail page
      Navigator.of(context).pop();
      // Remove last tweet from tweet detail stack page
      // state.removeLastTweetDetail(tweetId);
    }
  }

  void openRetweetbottomSheet(
    BuildContext context, {
    TweetType type,
    FeedModel model,
    @required Future<FeedModel> Function(String key) fetchTweet,
    @required void Function(FeedModel model) onRetweet,
    @required void Function(FeedModel model) onTweetUpdate,
  }) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 5, bottom: 0),
          height: 130,
          width: context.width,
          decoration: BoxDecoration(
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: _retweet(
            context,
            model,
            type,
            onRetweet: onRetweet,
            fetchTweet: fetchTweet,
            onTweetUpdate: onTweetUpdate,
          ),
        );
      },
    );
  }

  Widget _retweet(
    BuildContext context,
    FeedModel model,
    TweetType type, {
    Future<FeedModel> Function(String key) fetchTweet,
    Function(FeedModel model) onRetweet,
    Function(FeedModel model) onTweetUpdate,
  }) {
    return Column(
      children: <Widget>[
        Container(
          width: context.width * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.retweet,
          isEnable: true,
          text: 'Retweet',
          onPressed: () async {
            // var state = Provider.of<FeedState>(context, listen: false);
            var authState = Provider.of<AuthState>(context, listen: false);
            var myUser = authState.userModel;
            myUser = UserModel(
                displayName: myUser.displayName ?? myUser.email.split('@')[0],
                profilePic: myUser.profilePic,
                userId: myUser.userId,
                isVerified: authState.userModel.isVerified,
                userName: authState.userModel.userName);
            // Prepare current Tweet model to reply
            FeedModel post = new FeedModel(
                childRetwetkey: model.getTweetKeyToRetweet,
                createdAt: DateTime.now().toUtc().toString(),
                user: myUser,
                userId: myUser.userId);
            // state.createTweet(post);
            onRetweet(post);

            Navigator.pop(context);
            var sharedPost = await fetchTweet(post.childRetwetkey);
            if (sharedPost.retweetCount == null) {
              sharedPost.retweetCount = 0;
            }
            sharedPost.retweetCount += 1;
            onTweetUpdate(sharedPost);
            // state.updateTweet(sharedPost);
          },
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.edit,
          text: 'Retweet with comment',
          isEnable: true,
          onPressed: () {
            Navigator.pop(context);

            /// To simple reply on any `Tweet` set `isRetweet` to true.
            Navigator.of(context).push(
              ComposeTweetPage.getRoute(
                  isRetweet: true, tweetToReplyModel: model),
            );
          },
        )
      ],
    );
  }

  void openShareTweetBottomSheet(BuildContext context, FeedModel model,
      TweetType type, Future<FeedModel> Function(String key) fetchTweet) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: 130,
            width: context.width,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: _shareTweet(context, model, type, fetchTweet));
      },
    );
  }

  Widget _shareTweet(
    BuildContext context,
    FeedModel model,
    TweetType type,
    Future<FeedModel> Function(String key) fetchTweet,
  ) {
    var socialMetaTagParameters = SocialMetaTagParameters(
        description: model.description ?? "",
        title: "${model.user.displayName} posted a tweet on Fwitter.",
        imageUrl: Uri.parse(model.user?.profilePic ??
            "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw"));
    return Column(
      children: <Widget>[
        Container(
          width: context.width * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.link,
          isEnable: true,
          text: 'Share Link',
          onPressed: () async {
            Navigator.pop(context);
            var url = Utility.createLinkToShare(
              context,
              "tweet/${model.key}",
              socialMetaTagParameters: socialMetaTagParameters,
            );
            var uri = await url;
            Utility.share(uri.toString(), subject: "Tweet");
          },
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.image,
          text: 'Share with Tweet thumbnail',
          isEnable: true,
          onPressed: () {
            socialMetaTagParameters = SocialMetaTagParameters(
                description: model.description ?? "",
                title: "${model.user.displayName} posted a tweet on Fwitter.",
                imageUrl: Uri.parse(model.user?.profilePic ??
                    "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw"));
            Navigator.pop(context);
            Navigator.push(
              context,
              ShareWidget.getRoute(
                  child: Tweet(
                    model: model,
                    type: type,
                    onTweetAction: null,
                    fetchTweet: fetchTweet,
                    onRetweet: null,
                    onTweetUpdate: null,
                  ),
                  id: "tweet/${model.key}",
                  socialMetaTagParameters: socialMetaTagParameters),
            );
          },
        )
      ],
    );
  }
}
