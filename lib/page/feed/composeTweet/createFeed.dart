import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/page/feed/composeTweet/widget/composeBottomIconWidget.dart';
import 'package:flutter_twitter_clone/page/feed/composeTweet/widget/composeTweetImage.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class CreateFeedPage extends StatefulWidget {
  CreateFeedPage({Key key}) : super(key: key);

  _CreateFeedPageState createState() => _CreateFeedPageState();
}

class _CreateFeedPageState extends State<CreateFeedPage> {
  bool reachToOver = false;
  bool reachToWarning = false;
  Color wordCountColor;
  File _image;
  TextEditingController _textEditingController;

  @override
  void initState() {
    wordCountColor = Colors.blue;
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Widget _descriptionEntry() {
    return TextField(
      controller: _textEditingController,
      onChanged: (value) {
        setState(() {
          if (_textEditingController.text != null &&
              _textEditingController.text.isNotEmpty) {
            if (_textEditingController.text.length > 259 &&
                _textEditingController.text.length < 280) {
              wordCountColor = Colors.orange;
            } else if (_textEditingController.text.length >= 280) {
              wordCountColor = Theme.of(context).errorColor;
            } else {
              wordCountColor = Colors.blue;
            }
          }
        });
      },
      maxLines: null,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'What\'s happening?',
          hintStyle: TextStyle(fontSize: 18)),
    );
  }

  void _submitButton() async {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty ||
        _textEditingController.text.length > 280) {
      return;
    }
    var state = Provider.of<FeedState>(context);
    var authState = Provider.of<AuthState>(context);
    if (state.isBusy) {
      return;
    }
    // state.isBusy = true;
    kScreenloader.showLoader(context);
    var name = authState.userModel.displayName ??
        authState.userModel.email.split('@')[0];
    var pic = authState.userModel.profilePic ?? dummyProfilePic;
    var tags = getHashTags(_textEditingController.text);
    User user = User(
        displayName: name,
        userName: authState.userModel.userName,
        isVerified: authState.userModel.isVerified,
        profilePic: pic,
        userId: authState.userId);
    FeedModel _model = FeedModel(
      description: _textEditingController.text,
      userId: authState.userModel.userId,
      tags: tags,
      user: user,
      createdAt: DateTime.now().toUtc().toString(),
    );
    if (_image != null) {
      await state.uploadFile(_image).then(
        (imagePath) {
          if (imagePath != null) {
            _model.imagePath = imagePath;
            state.createTweet(_model);
          }
        },
      );
    } else {
      state.createTweet(_model);
    }
    // state.isBusy = false;
    kScreenloader.hideLoader();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(
      context,
    );
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: CustomAppBar(
        title: customTitleText(
          '',
        ),
        onActionPressed: _submitButton,
        isCrossButton: true,
        submitButtonText: 'Tweet',
        isSubmitDisable: _textEditingController.text == null ||
            _textEditingController.text.isEmpty ||
            _textEditingController.text.length > 280 ||
            Provider.of<FeedState>(context).isBusy,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        customImage(context,
                            state.userModel?.profilePic ?? dummyProfilePic),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: _descriptionEntry(),
                        )
                      ],
                    ),
                    ComposeTweetImage(
                      image: _image,
                      onCrossIconPressed: () {
                        setState(() {
                          _image = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ComposeBottomIconWidget(
                textEditingController: _textEditingController,
                onImageIconSelcted: (file) {
                  setState(() {
                    _image = file;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
