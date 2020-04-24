import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:flutter_twitter_clone/page/feed/composeTweet/widget/composeBottomIconWidget.dart';
import 'package:flutter_twitter_clone/page/feed/composeTweet/widget/composeTweetImage.dart';
import 'package:flutter_twitter_clone/page/feed/composeTweet/widget/widgetView.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class ComposeTweetPage extends StatefulWidget {
  ComposeTweetPage({Key key, this.isRetweet, this.isTweet = true})
      : super(key: key);

  final bool isRetweet;
  final bool isTweet;
  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends State<ComposeTweetPage> {
  bool isScrollingDown = false;
  FeedModel model;
  ScrollController scrollcontroller;

  File _image;
  TextEditingController _textEditingController;

  @override
  void dispose() {
    scrollcontroller.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.tweetToReplyModel;
    scrollcontroller = ScrollController();
    _textEditingController = TextEditingController();
    scrollcontroller..addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        setState(() {
          isScrollingDown = true;
        });
      }
    }
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
        isScrollingDown = false;
        // scrollcontroller.animateTo(scrollcontroller.position.minScrollExtent,
        //     duration: Duration(milliseconds: 300), curve: Curves.ease);
      });
    }
  }

  void _ontweetDescriptionChanged(String text) {
    setState(() {});
  }

  void _onCrossIconPressed() {
    setState(() {
      _image = null;
    });
  }

  void _onImageIconSelcted(File file) {
    setState(() {
      _image = file;
    });
  }

  void _submitButton() async {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty ||
        _textEditingController.text.length > 280) {
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    kScreenloader.showLoader(context);
    var user = authState.userModel;
    var profilePic = user.profilePic ?? dummyProfilePic;
    var tags = getHashTags(_textEditingController.text);
    var commentedUser = User(
        displayName: user.displayName ?? user.email.split('@')[0],
        profilePic: profilePic,
        userId: user.userId,
        isVerified: authState.userModel.isVerified,
        userName: authState.userModel.userName);

    FeedModel reply = FeedModel(
        description: _textEditingController.text,
        user: commentedUser,
        createdAt: DateTime.now().toUtc().toString(),
        tags: tags,
        parentkey: widget.isRetweet ? null : state.tweetToReplyModel.key,
        childRetwetkey: widget.isRetweet ? model.key : null,
        userId: commentedUser.userId);
    if (_image != null) {
      await state.uploadFile(_image).then((imagePath) {
        if (imagePath != null) {
          reply.imagePath = imagePath;
          if (widget.isRetweet) {
            state.createReTweet(reply);
          } else {
            state.addcommentToPost(reply);
          }
        }
      });
    } else {
      if (widget.isRetweet) {
        state.createReTweet(reply);
      } else {
        state.addcommentToPost(reply);
      }
    }
    kScreenloader.hideLoader();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // final composeState = Provider.of<ComposeTweetState>(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: customTitleText(''),
        onActionPressed: _submitButton,
        isCrossButton: true,
        submitButtonText:
            widget.isTweet ? 'Tweet' : widget.isRetweet ? 'Retweet' : 'Reply',
        isSubmitDisable: !Provider.of<ComposeTweetState>(context).enableSubmitButton ||
            Provider.of<FeedState>(context).isBusy,
        isbootomLine: isScrollingDown,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollcontroller,
              child: widget.isRetweet
                  ? _ComposeRetweet(this)
                  : _ComposeTweet(this),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ComposeBottomIconWidget(
                textEditingController: _textEditingController,
                onImageIconSelcted: _onImageIconSelcted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposeRetweet
    extends WidgetView<ComposeTweetPage, _ComposeTweetReplyPageState> {
  _ComposeRetweet(this.viewState) : super(viewState);

  final _ComposeTweetReplyPageState viewState;
  Widget _tweet(BuildContext context, FeedModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // SizedBox(width: 10),

        SizedBox(width: 20),
        Container(
          width: fullWidth(context) - 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: 25,
                    height: 25,
                    child: customImage(context, model.user.profilePic),
                  ),
                  SizedBox(width: 10),
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
                  Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
        UrlText(
          text: model.description,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          urlStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _descriptionEntry() {
    return TextField(
      controller: viewState._textEditingController,
      onChanged: viewState._ontweetDescriptionChanged,
      maxLines: null,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Add a comment',
          hintStyle: TextStyle(fontSize: 18, color: AppColor.darkGrey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: customImage(context, authState.user?.photoUrl, height: 40),
            ),
            Expanded(
              child: _descriptionEntry(),
            ),
            SizedBox(
              width: 16,
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 16, left: 80, bottom: 8),
          child: ComposeTweetImage(
            image: viewState._image,
            onCrossIconPressed: viewState._onCrossIconPressed,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 75, right: 16, bottom: 16),
          padding: EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
              border: Border.all(color: AppColor.extraLightGrey, width: .5),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: _tweet(context, viewState.model),
        ),
        SizedBox(height: 50)
      ],
    );
  }
}

class _ComposeTweet
    extends WidgetView<ComposeTweetPage, _ComposeTweetReplyPageState> {
  _ComposeTweet(this.viewState) : super(viewState);

  final _ComposeTweetReplyPageState viewState;
  List<User> list;
  String name = "";

  Widget _descriptionEntry(BuildContext context) {
    final searchState = Provider.of<SearchState>(context);
    list = searchState.userlist;
    // print(list.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: viewState._textEditingController,
          onChanged: (text) {
            Provider.of<ComposeTweetState>(context, listen: false)
                .onDescriptionChanged(text, searchState);
          },
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  widget.isTweet ? 'What\'s happening?' : 'Tweet your reply',
              hintStyle: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _tweerCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 40),
              margin: EdgeInsets.only(left: 20, top: 20, bottom: 3),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2.0,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: fullWidth(context) - 82,
                    child: UrlText(
                      text: viewState.model.description ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      urlStyle: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  UrlText(
                    text:
                        'Replying to ${viewState.model.user.userName ?? viewState.model.user.displayName}',
                    style: TextStyle(
                      color: TwitterColor.paleSky,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                customImage(context, viewState.model.user.profilePic,
                    height: 40),
                SizedBox(
                  width: 20,
                ),
                UrlText(
                  text: viewState.model.user.displayName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                viewState.model.user.isVerified
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
                  width: viewState.model.user.isVerified ? 5 : 0,
                ),
                customText('${viewState.model.user.userName}',
                    style: userNameStyle),
                SizedBox(width: 10),
                customText('- ${getChatTime(viewState.model.createdAt)}',
                    style: userNameStyle),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context,listen: false);
    // final searchState = Provider.of<SearchState>(context);
    // list = searchState.userlist;
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            height: fullHeight(context),
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                viewState.widget.isTweet
                    ? SizedBox.shrink()
                    : _tweerCard(context),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    customImage(context, authState.user?.photoUrl, height: 40),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: _TextField(
                        isTweet: widget.isTweet,
                        textEditingController: viewState._textEditingController,
                      ),
                    )
                  ],
                ),
                Flexible(
                  child: Stack(
                    children: <Widget>[
                      ComposeTweetImage(
                        image: viewState._image,
                        onCrossIconPressed: viewState._onCrossIconPressed,
                      ),
                      _UserList(
                        list: Provider.of<SearchState>(context).userlist,
                        textEditingController: viewState._textEditingController,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({Key key, this.textEditingController, this.isTweet})
      : super(key: key);
  final TextEditingController textEditingController;
  final bool isTweet;

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context,listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: textEditingController,
          onChanged: (text) {
            Provider.of<ComposeTweetState>(context, listen: false)
                .onDescriptionChanged(text, searchState);
          },
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isTweet ? 'What\'s happening?' : 'Tweet your reply',
              hintStyle: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({Key key, this.list, this.textEditingController})
      : super(key: key);
  final List<User> list;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return !Provider.of<ComposeTweetState>(context).displayUserList ||
            list == null ||
            list.length < 0 ||
            list.length == 0
        ? SizedBox.shrink()
        : Container(
            padding: EdgeInsetsDirectional.only(bottom: 50),
            color: TwitterColor.white,
            constraints:
                BoxConstraints(minHeight: 30, maxHeight: double.infinity),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return _UserTile(
                  user: list[index],
                  onUserSelected: (user) {
                    print(user.userName);
                    textEditingController.text +=
                        user.userName.substring(1, user.userName.length) + " ";

                    textEditingController.selection = TextSelection.collapsed(
                        offset: textEditingController.text.length);
                    Provider.of<ComposeTweetState>(context).onUserSelected();
                  },
                );
              },
            ),
          );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key key, this.user, this.onUserSelected}) : super(key: key);
  final User user;
  final ValueChanged<User> onUserSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onUserSelected(user);
      },
      leading: customImage(context, user.profilePic, height: 35),
      title: Row(
        children: <Widget>[
          Flexible(
            child: UrlText(
              text: user.displayName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 3),
          user.isVerified
              ? customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  istwitterIcon: true,
                  iconColor: AppColor.primary,
                  size: 13,
                  paddingIcon: 3,
                )
              : SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName),
    );
  }
}
