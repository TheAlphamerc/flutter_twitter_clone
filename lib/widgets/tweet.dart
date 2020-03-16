import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/page/feed/widgets/tweetIconsRow.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:provider/provider.dart';

import 'customWidgets.dart';
import 'newWidget/customUrlText.dart';

class Tweet extends StatelessWidget {
  final FeedModel model;
  final Widget trailing;
  final TweetType type;
  Tweet({Key key, this.model, this.trailing, this.type = TweetType.Tweet})
      : super(key: key);

  Widget _tweetImage(BuildContext context, String _image, String key) {
    return _image == null
        ? Container()
        : Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              onTap: () {
                var state = Provider.of<FeedState>(context, listen: false);
                state.getpostDetailFromDatabase(key);
                Navigator.pushNamed(context, '/ImageViewPge');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Container(
                  width: fullWidth(context) *
                      (type == TweetType.Detail ? .95 : .8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: customNetworkImage(_image, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          );
  }

  Widget _detailTweet(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: fullWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/ProfilePage/' + model?.userId);
                  },
                  child: customImage(context, model.user.profilePic),
                ),
                title: Row(
                  children: <Widget>[
                    UrlText(
                      text: model.user.displayName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 3),
                    model.user.isVerified
                        ? customIcon(
                            context,
                            icon: AppIcon.blueTick,
                            istwitterIcon: true,
                            iconColor: AppColor.primary,
                            size: 13,
                            paddingIcon: 3,
                          )
                        : SizedBox(width: 0),
                    SizedBox(
                      width: model.user.isVerified ? 5 : 0,
                    ),
                  ],
                ),
                subtitle:
                    customText('${model.user.userName}', style: userNameStyle),
                trailing: trailing,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: UrlText(
                  text: model.description,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: type == TweetType.Tweet
                          ? 15
                          : type == TweetType.Detail ? 18 : 14,
                      fontWeight:
                          type == TweetType.Tweet || type == TweetType.Tweet
                              ? FontWeight.w300
                              : FontWeight.w400),
                  urlStyle: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _tweet(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 10),
        Container(
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/ProfilePage/' + model?.userId);
            },
            child: customImage(context, model.user.profilePic),
          ),
        ),
        SizedBox(width: 20),
        Container(
          width: fullWidth(context) - 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        UrlText(
                          text: model.user.displayName,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 3),
                        model.user.isVerified
                            ? customIcon(
                                context,
                                icon: AppIcon.blueTick,
                                istwitterIcon: true,
                                iconColor: AppColor.primary,
                                size: 13,
                                paddingIcon: 3,
                              )
                            : SizedBox(width: 0),
                        SizedBox(
                          width: model.user.isVerified ? 5 : 0,
                        ),
                        Flexible(
                          child: customText(
                            '${model.user.userName}',
                            style: userNameStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        customText('· ${getChatTime(model.createdAt)}',
                            style: userNameStyle),
                      ],
                    ),
                  ),
                  Container(child: trailing == null ? SizedBox() : trailing),
                ],
              ),
              UrlText(
                text: model.description,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: type == TweetType.Tweet
                      ? 15
                      : type == TweetType.Detail ? 18 : 14,
                  fontWeight: type == TweetType.Tweet || type == TweetType.Tweet
                      ? FontWeight.w400
                      : FontWeight.w400,
                ),
                urlStyle:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var feedstate = Provider.of<FeedState>(context);
    return InkWell(
      onLongPress: () {
        if (type == TweetType.Detail) {
          var text = ClipboardData(text: model.description);
          Clipboard.setData(text);
          Scaffold.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).disabledColor,
              content: Text(
                'Tweet copied',
              ),
            ),
          );
        }
      },
      onTap: () {
        if (type == TweetType.Detail) {
          return;
        }
        if (type == TweetType.Tweet) {
          feedstate.clearAllDetailAndReplyTweetStack();
        }
        feedstate.getpostDetailFromDatabase(null, model: model);
        Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: type == TweetType.Tweet || type == TweetType.Reply
                ? _tweet(context)
                : _detailTweet(context),
          ),
          _tweetImage(context, model.imagePath, model.key),
          Padding(
            padding: EdgeInsets.only(left: type == TweetType.Detail ? 10 : 60),
            child: TweetIconsRow(
              type: type,
              model: model,
              isTweetDetail: type == TweetType.Detail,
              iconColor: Theme.of(context).textTheme.caption.color,
              iconEnableColor: TwitterColor.ceriseRed,
              size: 20,
            ),
          ),
          Divider(height: .5,thickness: .5,)
        ],
      ),
    );
  }
}
