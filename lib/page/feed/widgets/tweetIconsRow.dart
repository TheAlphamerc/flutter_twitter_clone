import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class TweetIconsRow extends StatefulWidget {
  final FeedModel model;
  final Color iconColor;
  final Color iconEnableColor;
  final double size;
  final bool isTweetDetail;
  final TweetType type;
  const TweetIconsRow({Key key, this.model, this.iconColor, this.iconEnableColor, this.size, this.isTweetDetail = false, this.type}) : super(key: key);

  _TweetIconsRowState createState() => _TweetIconsRowState();
}

class _TweetIconsRowState extends State<TweetIconsRow> {
 
  Widget _likeCommentsIcons(FeedModel model) {
    var state = Provider.of<AuthState>(context,);
    var feedstate = Provider.of<FeedState>(context,);
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: 0,top:0),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 20,),
          _iconWidget(
            text: widget.isTweetDetail ? '' : model.commentCount.toString(),
            icon:AppIcon.reply,iconColor: widget.iconColor,
            size : widget.size ?? 20,
            onPressed: (){
              if(widget.type == TweetType.Reply){
                return;
              }
              feedstate.setFeedModel = model;
              Navigator.of(context).pushNamed('/FeedPostReplyPage/'+model.key);
            },),
          _iconWidget(
            text:widget.isTweetDetail ? '' : model.commentCount.toString(),
            icon:AppIcon.retweet,iconColor: widget.iconColor,size : widget.size ?? 20),
          _iconWidget(
            text:widget.isTweetDetail ? '' : model.likeCount.toString(),
            icon:model.likeList.any((x)=>x.userId == state.userId) 
            ? AppIcon.heartFill 
            : AppIcon.heartEmpty,
            onPressed:(){addLikeToTweet();},
            iconColor: model.likeList.any((x)=>x.userId == state.userId )? widget.iconEnableColor : widget.iconColor ,
            size : widget.size ?? 20
          ),
          _iconWidget(
            text:'',
            icon:null,
            sysIcon:Icons.share,
            onPressed: (){share('social.flutter.dev/feed/${model.key}',
            subject:'${model.user.displayName}\'s post');},
            iconColor: widget.iconColor,
            size : widget.size ?? 20),
         
        ],
    )
    );
  }
  Widget _iconWidget({String text, int icon,Function onPressed,IconData sysIcon,Color iconColor, double size = 20}){
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
  Widget _timeWidget(){
   return Column(children: <Widget>[
     SizedBox(height: 15,),
      Row(
        children: <Widget>[
          customText(getPostTime2(widget.model.createdAt),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54)),
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
            customText(widget.model.commentCount.toString(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              width: 10,
            ),
            customText('comments', style: TextStyle(color: Colors.black54)),
            SizedBox(
              width: 20,
            ),
            customSwitcherWidget(
              duraton: Duration(milliseconds: 300),
              child: customText(widget.model.likeCount.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                  key: ValueKey(widget.model.likeCount)),
            ),
            SizedBox(
              width: 10,
            ),
            customText('Likes', style: TextStyle(color: Colors.black54))
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
  void addLikeToTweet() {
    var state = Provider.of<FeedState>(context,);
    var authState = Provider.of<AuthState>(context,);
    state.addLikeToTweet(widget.model.key, authState.userId);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
       child:Column(children: <Widget>[
          widget.isTweetDetail ?  _timeWidget() : SizedBox(),
          widget.isTweetDetail ? _likeCommentWidget() : SizedBox(),
        
         _likeCommentsIcons(widget.model)
       ],)
    );
  }
}