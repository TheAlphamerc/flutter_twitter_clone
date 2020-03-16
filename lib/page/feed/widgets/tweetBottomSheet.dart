import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class TweetBottomSheet {
  Widget tweetOptionIcon(BuildContext context, FeedModel model, TweetType type){
    return  customInkWell(
        radius: BorderRadius.circular(20),
        context: context,
        onPressed: (){_openbottomSheet(context,type,model);},
        child:Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child:customIcon(context,
                        icon: AppIcon.arrowDown,
                        istwitterIcon: true,
                        iconColor: AppColor.lightGrey),
        )
                
      );
  }
  void _openbottomSheet(
      BuildContext context, TweetType type, FeedModel model) async {
    var authState = Provider.of<AuthState>(
      context,
    );
    bool isMyTweet = authState.userId == model.userId;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 5, bottom: 0),
          height: fullHeight(context) *  ( type == TweetType.Tweet ?  (isMyTweet ? .25 :  .44) :  (isMyTweet ? .38 :  .52)),
          width: fullWidth(context),
          decoration: BoxDecoration(
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: type == TweetType.Tweet ?  _tweetOptions(context, isMyTweet, model,type)
          : _tweetDetailOptions(context, isMyTweet, model,type)
          
        );
      },
    );
  }
  Widget _tweetDetailOptions(BuildContext context, bool isMyTweet, FeedModel model, TweetType type){
    return Column(
      children: <Widget>[
        Container(
          width: fullWidth(context) * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(context,AppIcon.link,text: 'Copy link to tweet',),
        isMyTweet? _widgetBottomSheetRow(context,AppIcon.unFollow,text: 'Pin to profile',)
            : _widgetBottomSheetRow(context,AppIcon.unFollow,text: 'Unfollow ${model.user.userName}',),
        isMyTweet? _widgetBottomSheetRow(context,AppIcon.delete,text: 'Delete Tweet',
            onPressed: () {
                  _deleteTweet(context,type,model.key,parentkey: model.parentkey,);
                },
                isEnable: true,
              )
            : Container(),
              
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context,AppIcon.mute,text: 'Mute ${model.user.userName}',),
        _widgetBottomSheetRow(context,AppIcon.mute,text: 'Mute this convertion',),
        _widgetBottomSheetRow(context,AppIcon.viewHidden,text: 'View hidden replies',),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context,AppIcon.block,text: 'Block ${model.user.userName}',),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context,AppIcon.report,text: 'Report Tweet',),
      ],
    );
  }
   Widget _tweetOptions(BuildContext context, bool isMyTweet, FeedModel model, TweetType type){
    return Column(
      children: <Widget>[
        Container(
          width: fullWidth(context) * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(context,AppIcon.link,text: 'Copy link to tweet',),
        isMyTweet? _widgetBottomSheetRow(context,AppIcon.thumbpinFill,text: 'Pin to profile',)
            : _widgetBottomSheetRow(context,AppIcon.sadFace,text: 'Not interested in this',),
        isMyTweet? _widgetBottomSheetRow(context,AppIcon.delete,text: 'Delete Tweet',
            onPressed: () {_deleteTweet(context,type,model.key,parentkey: model.parentkey,);},
                isEnable: true,
              )
            : Container(),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context,AppIcon.unFollow,text: 'Unfollow ${model.user.userName}',),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context,AppIcon.mute,text: 'Mute ${model.user.userName}',),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context,AppIcon.block,text: 'Block ${model.user.userName}',),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context,AppIcon.report,text: 'Report Tweet',),
      ],
    );
  }
  Widget _widgetBottomSheetRow(BuildContext context, int icon,
      {String text, Function onPressed, bool isEnable = false}) {
    return Expanded(
      child: customInkWell(
        context: context,
        onPressed: () {
          if (onPressed != null) onPressed();
          else{
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              customIcon(
                context,
                icon: icon,
                istwitterIcon: true,
                size: 25,
                iconColor: isEnable ? AppColor.darkGrey : AppColor.lightGrey,
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
        ),
      ),
    );
  }

  void _deleteTweet(BuildContext context, TweetType type, String tweetId,
      {String parentkey}) {
    var state = Provider.of<FeedState>(
      context,
    );
    state.deleteTweet(tweetId, type, parentkey: parentkey);
    // CLose bottom sheet 
    Navigator.of(context).pop();
    if (type == TweetType.Detail){
      // Close Tweet detail page
      Navigator.of(context).pop();
      // Remove last tweet from tweet detail stack page
      state.removeLastTweetDetail(tweetId);
    } 
  }
}
