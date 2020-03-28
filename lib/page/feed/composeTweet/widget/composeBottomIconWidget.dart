import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:image_picker/image_picker.dart';

class ComposeBottomIconWidget extends StatefulWidget {
  
  final TextEditingController textEditingController;
  final Function(File) onImageIconSelcted;
  ComposeBottomIconWidget({Key key, this.textEditingController, this.onImageIconSelcted}) : super(key: key);
  
  @override
  _ComposeBottomIconWidgetState createState() => _ComposeBottomIconWidgetState();
}

class _ComposeBottomIconWidgetState extends State<ComposeBottomIconWidget> {

 bool reachToWarning = false;
 bool reachToOver = false;
 Color wordCountColor;
 String tweet = '';
 
 @override
 void initState() { 
   wordCountColor = Colors.blue;
   widget.textEditingController.addListener(updateUI);
   super.initState();
 }
 void updateUI(){
   setState(() {
     tweet = widget.textEditingController.text;
     if (widget.textEditingController.text != null &&
          widget.textEditingController.text.isNotEmpty) {
            if (widget.textEditingController.text.length > 259 &&
                widget.textEditingController.text.length < 280) {
              wordCountColor = Colors.orange;
            } else if (widget.textEditingController.text.length >= 280) {
              wordCountColor = Theme.of(context).errorColor;
            } else {
              wordCountColor = Colors.blue;
            }
           }
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
                child: tweet != null &&
                        tweet.length > 289
                    ? Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: customText(
                            '${280 - tweet.length}',
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
                          tweet.length > 259
                              ? customText(
                                  '${280 - tweet.length}',
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
  void setImage(ImageSource source) {
    ImagePicker.pickImage(source: source, imageQuality: 20).then((File file) {
      setState(() {
        // _image = file;
        widget.onImageIconSelcted(file);
      });
    });
  }
  double getTweetLimit() {
    if (tweet == null ||
        tweet.isEmpty) {
      return 0.0;
    }
    if (tweet.length > 280) {
      return 1.0;
    }
    var length = tweet.length;
    var val = length * 100 / 28000.0;
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: _bottomIconWidget(),
    );
  }
}