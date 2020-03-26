import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/page/feed/widgets/tweetBottomSheet.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class TweetIconsRow extends StatelessWidget {
  final FeedModel model;
  final Color iconColor;
  final Color iconEnableColor;
  final double size;
  final bool isTweetDetail;
  final TweetType type;
  const TweetIconsRow({Key key, this.model, this.iconColor, this.iconEnableColor, this.size, this.isTweetDetail = false, this.type}) : super(key: key);

  Widget _likeCommentsIcons(BuildContext context, FeedModel model) {
    var state = Provider.of<AuthState>(context,);
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: 0,top:0),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 20,),
          _iconWidget(
            context,
            text: isTweetDetail ? '' : model.commentCount.toString(),
            icon:AppIcon.reply,iconColor: iconColor,
            size : size ?? 20,
            onPressed: (){
              var state = Provider.of<FeedState>(context,);
              state.setTweetToReply = model;
              Navigator.of(context).pushNamed('/FeedPostReplyPage');
            },),
          _iconWidget(
            context,
            text:isTweetDetail ? '' : model.retweetCount.toString(),
            icon:AppIcon.retweet,iconColor: iconColor,size : size ?? 20,
            onPressed: (){
              TweetBottomSheet().openRetweetbottomSheet(context, type, model);
            }
            ),
          _iconWidget(
            context,
            text:isTweetDetail ? '' : model.likeCount.toString(),
            icon:model.likeList.any((x)=>x.userId == state.userId) 
            ? AppIcon.heartFill 
            : AppIcon.heartEmpty,
            onPressed:(){addLikeToTweet(context);},
            iconColor: model.likeList.any((x)=>x.userId == state.userId )? iconEnableColor : iconColor ,
            size : size ?? 20
          ),
          _iconWidget(
            context,
            text:'',
            icon:null,
            sysIcon:Icons.share,
            onPressed: (){share('${model.description}',
            subject:'${model.user.displayName}\'s post');},
            iconColor: iconColor,
            size : size ?? 20),
         
        ],
    )
    );
  }
  Widget _iconWidget(BuildContext context,{String text, int icon,Function onPressed,IconData sysIcon,Color iconColor, double size = 20}){
    return Expanded(
      child:Container(
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed:(){ if(onPressed != null)onPressed();},
              icon: sysIcon != null ? Icon( sysIcon,color:iconColor,size:size)
              : customIcon(context,size: size, icon:icon, istwitterIcon: true, iconColor: iconColor),
            ),
            customText(text,style: TextStyle(fontWeight: FontWeight.bold, color:iconColor, fontSize: size - 5,),context: context),
          ],
        )
      )
    );
  }
  Widget _timeWidget(BuildContext context){
   return Column(children: <Widget>[
     SizedBox(height: 5,),
      Row(
        children: <Widget>[
          SizedBox(width: 5,),
          customText(getPostTime2(model.createdAt),
              style: textStyle14),
          SizedBox(
            width: 10,
          ),
          customText('Twitter for Android',
              style: TextStyle(color: Theme.of(context).primaryColor))
        ],
    ),
    SizedBox(height: 5,),
   ],);
  }
  Widget _likeCommentWidget(){
    return Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.only(right: 10),
          child: Divider(),
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            customText(model.retweetCount.toString(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              width: 5,
            ),
            customText('Retweets', style:subtitleStyle),
            SizedBox(
              width: 20,
            ),
            customSwitcherWidget(
              duraton: Duration(milliseconds: 300),
              child: customText(model.likeCount.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                  key: ValueKey(model.likeCount)),
            ),
            SizedBox(
              width: 5,
            ),
            customText('Likes', style: subtitleStyle)
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Divider(),
        ),
    ],);
  }
  void addLikeToTweet(BuildContext context) {
    var state = Provider.of<FeedState>(context,);
    var authState = Provider.of<AuthState>(context,);
    state.addLikeToTweet(model, authState.userId);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
       child:Column(children: <Widget>[
          isTweetDetail ?  _timeWidget(context): SizedBox(),
          isTweetDetail ? _likeCommentWidget() : SizedBox(),
        
         _likeCommentsIcons(context, model)
       ],)
    );
  }
}