import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

import 'widgets/bottomIconWidget.dart';
import 'widgets/tweetImage.dart';

class FeedPostReplyPage extends StatefulWidget {
  FeedPostReplyPage({Key key, this.postId}) : super(key: key);
  final String postId;
  _FeedPostReplyPageState createState() => _FeedPostReplyPageState();
}

class _FeedPostReplyPageState extends State<FeedPostReplyPage> {
  TextEditingController _textEditingController;
  ScrollController scrollcontroller;
  bool isScrollingDown = false;
  String postId;
  File _image;
  FeedModel  model;
  @override
  void initState() {
    postId = widget.postId;
     var feedState = Provider.of<FeedState>(context,listen: false);
    
    /// if tweet is detail tweet
    if(feedState.tweetDetailModel.any((x)=>x.key == postId)){
      // cprint('Search tweet from tweet detail page stack tweet');
      model = feedState.tweetDetailModel.last;
    }
    /// if tweet is reply tweet
    else if(feedState.tweetReplyMap.values.any((x)=> x.any((y)=>y.key == postId))){
      // cprint('Search tweet from twee detail page  roply tweet');
        feedState.tweetReplyMap.forEach((key,value){
            if(value.any((x)=> x.key == postId)){
              model = value.firstWhere((x)=>x.key == postId);
            }
        });
    }
    else{
      // cprint('Search tweet from home page tweet');
      model = feedState.feedlist.firstWhere((x)=> x.key == postId);
    }
    scrollcontroller = ScrollController();
    _textEditingController = TextEditingController();
    scrollcontroller..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    scrollcontroller.dispose();
    _textEditingController.dispose();
    super.dispose();
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
        scrollcontroller.animateTo(scrollcontroller.position.minScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      });
    }
  }

  Widget _descriptionEntry() {
    return TextField(
      controller: _textEditingController,
      onChanged: (text) {
        setState(() {});
      },
      maxLines: null,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Tweet your reply',
          hintStyle: TextStyle(fontSize: 18)),
    );
  }

  Widget _tweerCard() {
   
    
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
                        text: model.description ?? '',
                          style: TextStyle(color: Colors.black,fontSize: 18 ,
                            fontWeight: FontWeight.w400),
                            urlStyle: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    UrlText(
                        text:
                            'Replying to ${model.user.userName ?? model.user.displayName}',
                        style: TextStyle(
                          color: TwitterColor.paleSky,
                          fontSize: 13,
                        )),
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                customImage(context, model.user.profilePic, height: 40),
                SizedBox(
                  width: 20,
                ),
                UrlText(
                  text: model.user.displayName,
                  style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w800,),
                ),
                SizedBox(width: 3,),
                model.user.isVerified ?
                customIcon(context,icon:AppIcon.blueTick, istwitterIcon: true,iconColor:  AppColor.primary, size:13,paddingIcon:3)
                :SizedBox(width: 0,),
                SizedBox(width: model.user.isVerified ? 5 : 0,),
                customText('${model.user.userName}',style: userNameStyle),
                SizedBox(width: 10,),
                customText('- ${getChatTime(model.createdAt)}',style: userNameStyle),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _submitButton() async {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty ||
        _textEditingController.text.length > 280) {
      return;
    }
    var state = Provider.of<FeedState>(
      context,
    );
    var authState = Provider.of<AuthState>(
      context,
    );
    if (state.isBusy) {
      print('API is busy');
      return;
    }
    var user = authState.user;
    var profilePic = user.photoUrl ?? dummyProfilePic;
    var tags = getHashTags(_textEditingController.text);
    var commentedUser = User(
        displayName: user.displayName ?? user.email.split('@')[0],
        profilePic: profilePic,
        userId: user.uid,
        userName: authState.userModel.userName);

    FeedModel reply = FeedModel(
        description: _textEditingController.text,
        user: commentedUser,
        createdAt: DateTime.now().toString(),
        tags: tags,
        parentkey : postId,
        userId: commentedUser.userId);
    if (_image != null) {
      await state.uploadFile(_image).then((imagePath) {
        if (imagePath != null) {
          reply.imagePath = imagePath;
          state.addcommentToPost(postId, reply);
        }
      });
    } else {
      state.addcommentToPost(postId, reply);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(
      context,
    );
    return Scaffold(
        appBar: CustomAppBar(
          title: customTitleText(
            '',
          ),
          onActionPressed: _submitButton,
          isCrossButton: true,
          submitButtonText: 'Reply',
          isSubmitDisable: _textEditingController.text == null ||
              _textEditingController.text.isEmpty ||
              _textEditingController.text.length > 280 ||
              state.isBusy,
          isbootomLine: isScrollingDown,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
            child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollcontroller,
              child: Container(
                height: fullHeight(context),
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _tweerCard(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        customImage(context, state.user?.photoUrl, height: 40),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: _descriptionEntry(),
                        )
                      ],
                    ),
                    TweetImage(
                      image: _image,
                      onCrossIconPressed: () {
                        setState(() {
                          _image = null;
                        });
                      },
                    ),
                    Expanded(
                      child: Container(),
                    )
                  ],
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: BottomIconWidget(
                  textEditingController: _textEditingController,
                  onImageIconSelcted: (file) {
                    setState(() {
                      _image = file;
                    });
                  },
                )),
            Align(
              alignment: Alignment.center,
              child: state.isBusy
                  ? Container(
                      height: fullHeight(context),
                      width: fullWidth(context),
                      color: Theme.of(context).disabledColor.withAlpha(50),
                      child: loader(),
                    )
                  : SizedBox(),
            )
          ],
        )));
  }
}
