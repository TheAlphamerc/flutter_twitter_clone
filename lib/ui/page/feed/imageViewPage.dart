import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/shared_prefrence_helper.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/tweetDetailState.dart';
import 'package:flutter_twitter_clone/ui/page/common/locator.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/cache_image.dart';
import 'package:flutter_twitter_clone/widgets/tweet/widgets/tweetIconsRow.dart';
import 'package:provider/provider.dart';

class ImageViewPage extends StatefulWidget {
  // final Function(FeedModel model) onCommentAdded;
  // final void Function(FeedModel) onRetweet;
  // final Future<FeedModel> Function(String) fetchTweet;
  // final void Function(FeedModel) onTweetUpdate;

  static Route<T> getRoute<T>({FeedModel model}) {
    return MaterialPageRoute(
      builder: (_) => Provider(
        create: (_) => TweetDetailState(),
        builder: (BuildContext context, Widget child) => child,
        child: ChangeNotifierProvider(
          create: (_) => TweetDetailState(tweet: model, isLoadComents: false),
          child: ImageViewPage(),
        ),
      ),
    );
  }

  const ImageViewPage({
    Key key,
    // this.onCommentAdded,
    // this.onTweetUpdate,
    // this.onRetweet,
    // this.fetchTweet,
  }) : super(key: key);
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  bool isToolAvailable = true;

  FocusNode _focusNode;
  TextEditingController _textEditingController;

  FeedModel get tweet => context.watch<TweetDetailState>().tweet;

  @override
  void initState() {
    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
    super.initState();
  }

  Widget _body() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
            color: Colors.brown.shade700,
            constraints: BoxConstraints(
              maxHeight: context.height,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  isToolAvailable = !isToolAvailable;
                });
              },
              child: _imageFeed(tweet.imagePath),
            ),
          ),
        ),
        !isToolAvailable
            ? Container()
            : Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.brown.shade700.withAlpha(200),
                      ),
                      child: Wrap(
                        children: <Widget>[
                          BackButton(
                            color: Colors.white,
                          ),
                        ],
                      )),
                )),
        !isToolAvailable
            ? Container()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TweetIconsRow(
                          model: tweet,
                          iconColor: Theme.of(context).colorScheme.onPrimary,
                          iconEnableColor:
                              Theme.of(context).colorScheme.onPrimary,
                          onTweetAction: (action, model) async {
                            var user = await getIt<SharedPreferenceHelper>()
                                .getUserProfile();

                            switch (action) {
                              case TweetAction.Like:
                                {
                                  context
                                      .read<TweetDetailState>()
                                      .handleTweetLike(model, user.key);
                                }

                                break;
                              default:
                                {
                                  cprint("Handle $action on ImageViewPage");
                                }
                            }
                          },
                          fetchTweet: (key) {
                            var model = context.read<TweetDetailState>().tweet;
                            return context
                                .read<TweetDetailState>()
                                .getpostDetailFromDatabase(model.key);
                          },
                          onRetweet: (model) {
                            context.read<TweetDetailState>().createPost(model);
                          },
                          onTweetUpdate: (model) {
                            context.read<TweetDetailState>().updateTweet(model);
                          }),
                      Container(
                        color: Colors.brown.shade700.withAlpha(200),
                        padding:
                            EdgeInsets.only(right: 10, left: 10, bottom: 10),
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: null,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            fillColor: Colors.blue,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _submitButton();
                              },
                              icon: Icon(Icons.send, color: Colors.white),
                            ),
                            focusColor: Colors.black,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            hintText: 'Comment here..',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _imageFeed(String _image) {
    return _image == null
        ? Container()
        : Container(
            alignment: Alignment.center,
            child: Container(
                child: InteractiveViewer(
              child: CacheImage(
                path: _image,
                fit: BoxFit.fitWidth,
              ),
            )),
          );
  }

  void _submitButton() {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty) {
      return;
    }
    if (_textEditingController.text.length > 280) {
      return;
    }
    // var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    var user = authState.userModel;
    var profilePic = user.profilePic;
    if (profilePic == null) {
      profilePic = Constants.dummyProfilePic;
    }
    var name = authState.userModel.displayName ??
        authState.userModel.email.split('@')[0];
    var pic = authState.userModel.profilePic ?? Constants.dummyProfilePic;
    var tags = Utility.getHashTags(_textEditingController.text);

    UserModel commentedUser = UserModel(
        displayName: name,
        userName: authState.userModel.userName,
        isVerified: authState.userModel.isVerified,
        profilePic: pic,
        userId: authState.userId);

    var postId = context.read<TweetDetailState>().tweet.key;

    FeedModel reply = FeedModel(
      description: _textEditingController.text,
      user: commentedUser,
      createdAt: DateTime.now().toUtc().toString(),
      tags: tags,
      userId: commentedUser.userId,
      parentkey: postId,
    );
    // state.addcommentToPost(reply);
    // onCommentAdded(reply);
    context.read<TweetDetailState>().addcomment(reply);
    FocusScope.of(context).requestFocus(_focusNode);
    setState(() {
      _textEditingController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }
}
