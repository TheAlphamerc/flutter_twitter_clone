import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/tweet.dart';
import 'package:provider/provider.dart';

class FeedPostDetail extends StatefulWidget {
  FeedPostDetail({Key key, this.postId}) : super(key: key);
  final String postId;

  _FeedPostDetailState createState() => _FeedPostDetailState();
}

class _FeedPostDetailState extends State<FeedPostDetail> {
  String postId;
  @override
  void initState() {
    postId = widget.postId;
    var state = Provider.of<FeedState>(context, listen: false);
    state.getpostDetailFromDatabase(postId);
    super.initState();
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/FeedPostReplyPage/' + postId);
      },
      child: Icon(Icons.add),
    );
  }

  Widget _commentRow(FeedModel model) {
      return Tweet(model:model,
      type: TweetType.Reply,
      trailing: customInkWell(
        radius: BorderRadius.circular(20),
        context: context,
        onPressed: (){openbottomSheet(TweetType.Reply,model.key);},
        child:Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // color: Colors.blue
          ),
          child:customIcon(context,
                        icon: AppIcon.arrowDown,
                        istwitterIcon: true,
                        iconColor: AppColor.lightGrey),
        )
                
      )
    );
  }

  Widget _postBody(FeedModel model) {
    return Tweet(model:model,
      isTweetDetail: true,
      trailing: customInkWell(
        radius: BorderRadius.circular(20),
        context: context,
        onPressed: (){openbottomSheet(TweetType.Tweet,model.key);},
        child:Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // color: Colors.blue
          ),
          child:customIcon(context,
                        icon: AppIcon.arrowDown,
                        istwitterIcon: true,
                        iconColor: AppColor.lightGrey),
        )
                
      )
    );
  }

  void openbottomSheet(TweetType type,String tweetId) async {
     var state = Provider.of<FeedState>(context,);
     var authState = Provider.of<AuthState>(context,);
     bool isMyTweet = authState.userId == state.feedModel.userId;
    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: fullHeight(context) * (isMyTweet ? .38 : .52),
            width: fullWidth(context),
            decoration: BoxDecoration(
                color: Theme.of(context).bottomSheetTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              children: <Widget>[
                Container(
                    width: fullWidth(context) * .1,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)))
                ),
                widgetBottomSheetRow(AppIcon.link,text:'Copy link to tweet'),
                isMyTweet ? widgetBottomSheetRow(AppIcon.unFollow,text:'Pin to profile') : widgetBottomSheetRow(AppIcon.unFollow,text:'Unfollow ${state.feedModel.user.userName}'),
                isMyTweet ? widgetBottomSheetRow(AppIcon.delete,text:'Delete Tweet', onPressed: (){deleteTweet(type,tweetId);},isEnable:true) : widgetBottomSheetRow(AppIcon.unFollow,text:'Unfollow ${state.feedModel.user.userName}'),
                isMyTweet ? Container() : widgetBottomSheetRow(AppIcon.mute,text:'Mute ${state.feedModel.user.userName}'),
                widgetBottomSheetRow(AppIcon.mute,text:'Mute this convertion'),
                widgetBottomSheetRow(AppIcon.viewHidden,text:'View hidden replies'),
                isMyTweet ? Container() : widgetBottomSheetRow(AppIcon.block,text:'Block ${state.feedModel.user.userName}'),
                isMyTweet ? Container() : widgetBottomSheetRow(AppIcon.report,text:'Report Tweet'),
              ],
            ),
          );
        });
  }

  Widget widgetBottomSheetRow(int icon, {String text, Function onPressed,bool isEnable = false}) {
    return Expanded(
      child:customInkWell(
      context: context, 
      onPressed: () {if(onPressed != null)onPressed();},
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              customIcon(context, icon:icon, istwitterIcon:true,size: 25,iconColor: isEnable ? AppColor.darkGrey : AppColor.lightGrey),
              SizedBox(width: 15,),
              customText(text,context:context,style: TextStyle(color: isEnable ? AppColor.secondary : AppColor.lightGrey,fontFamily: appFont, fontSize: 18,fontWeight: FontWeight.w400))
            ],
          ),
       ),
      )
    );
  }

  void addLikeToTweet(String postId) {
    var state = Provider.of<FeedState>(context,);
    var authState = Provider.of<AuthState>(context,);
    state.addLikeToTweet(postId, authState.userId);
  }

  void addLikeToComment(String commentId) {
    var state = Provider.of<FeedState>(
      context,
    );
    var authState = Provider.of<AuthState>(
      context,
    );
    state.addLikeToTweet(state.feedModel.key,authState.userId);
  }

  void openImage() async {
    Navigator.pushNamed(context, '/ImageViewPge');
  }
  void deleteTweet(TweetType type,String tweetId){
      var state = Provider.of<FeedState>(context,);
      state.deleteTweet(tweetId,type);
      Navigator.of(context).pop();
      if(type == TweetType.Tweet)
      Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(
      context,
    );
    return Scaffold(
        floatingActionButton: _floatingActionButton(),
        backgroundColor: Theme.of(context).backgroundColor,
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
              pinned: true,
              title: customTitleText('Thread'),
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              backgroundColor: Theme.of(context).appBarTheme.color,
              bottom: PreferredSize(
                  child: Container(
                    color: Colors.grey.shade200,
                    height: 1.0,
                  ),
                  preferredSize: Size.fromHeight(0.0))),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _postBody(state.feedModel),
                Container(
                height: 6,
                width: fullWidth(context),
                color: TwitterColor.mystic,
        )      
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
                state.commentlist == null || state.commentlist.length == 0
                    ? [
                        Container(
                            child: Center(
                                //  child: Text('No comments'),
                                ))
                      ]
                    : state.commentlist.map((x) => _commentRow(x)).toList()),
          )
        ]));
  }
}
