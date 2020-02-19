import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart' as prefix0;
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateFeedPage extends StatefulWidget {
  CreateFeedPage({Key key}) : super(key: key);
  _CreateFeedPageState createState() => _CreateFeedPageState();
}

class _CreateFeedPageState extends State<CreateFeedPage> {
  TextEditingController _textEditingController;
  File _image;
  bool reachToWarning = false;
  bool reachToOver = false;
  Color wordCountColor;
  @override
  void initState() {
    wordCountColor = Colors.blue;
    _textEditingController = TextEditingController();
    super.initState();
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

  Widget _imageFeed() {
    return _image == null
        ? Container()
        : Stack(
            children: <Widget>[
              Container(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 300,
                    width: fullWidth(context) * .8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        image: DecorationImage(
                            image: FileImage(_image), fit: BoxFit.cover)),
                  )),
              Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black26),
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      iconSize: 20,
                      onPressed: () {
                        setState(() {
                          _image = null;
                        });
                      },
                      icon: Icon(Icons.close,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ))
            ],
          );
  }

  void setImage(ImageSource source) {
    ImagePicker.pickImage(source: source, imageQuality: 50).then((File file) {
      setState(() {
        _image = file;
      });
    });
  }

  Widget _bottomIconWidget() {
    return Container(
      width: fullWidth(context),
      height: 50,
      decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          color: Theme.of(context).backgroundColor),
      child: Row(
        children: <Widget>[
          IconButton(
              onPressed: () {
                setImage(ImageSource.gallery);
              },
              icon: customIcon(context,
                  icon: AppIcon.image,
                  istwitterIcon: true,
                  iconColor: AppColor.primary)),
          IconButton(
              onPressed: () {
                setImage(ImageSource.camera);
              },
              icon: customIcon(context,
                  icon: AppIcon.camera,
                  istwitterIcon: true,
                  iconColor: AppColor.primary)),
          Expanded(
              child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: _textEditingController.text != null &&
                        _textEditingController.text.length > 289
                    ? Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: customText(
                            '${280 - _textEditingController.text.length}',
                            style:
                                TextStyle(color: Theme.of(context).errorColor)),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            value: getTweetLimit(),
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(wordCountColor),
                          ),
                          _textEditingController.text.length > 259
                              ? customText(
                                  '${280 - _textEditingController.text.length}',
                                  style: TextStyle(color: wordCountColor))
                              : customText('',
                                  style: TextStyle(color: wordCountColor))
                        ],
                      )),
          ))
        ],
      ),
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
    if(state.isBusy){
      return;
    }
    state.isBusy = true;
    var name = authState.userModel.displayName ??
        authState.userModel.email.split('@')[0];
    var pic = authState.userModel.profilePic ?? dummyProfilePic;
    var tags = getHashTags(_textEditingController.text);
    User user = User(
      displayName: name,
      userName: authState.userModel.userName,
      isVerified: authState.userModel.isVerified,
      profilePic: pic,
    );
    FeedModel _model = FeedModel(
        description: _textEditingController.text,
        userId: authState.user.uid,
        tags: tags,
        user: user,
        createdAt: DateTime.now().toString());
    if (_image != null) {
      await state.uploadFile(_image, _model);
    } else {
      state.createTweet(_model);
    }
    state.isBusy = false;
    Navigator.pop(context);
  }

  double getTweetLimit() {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty) {
      return 0.0;
    }
    if (_textEditingController.text.length > 280) {
      return 1.0;
    }
    var length = _textEditingController.text.length;
    var val = length * 100 / 28000.0;
    return val;
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
              _textEditingController.text.length > 280,
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
                    _imageFeed(),
                  ],
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter, child: _bottomIconWidget()),
          ],
        )));
  }
}
