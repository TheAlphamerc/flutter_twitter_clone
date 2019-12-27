import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:provider/provider.dart';

import 'customWidgets.dart';
import 'newWidget/customUrlText.dart';

class Tweet extends StatefulWidget {
   final FeedModel model;

  const Tweet({Key key, this.model}) : super(key: key);
  _TweetState createState() => _TweetState();
}

class _TweetState extends State<Tweet> {
  FeedModel _model;
  
   Widget _tweetImage(String _image,String key){
     return _image == null ? Container() :
     Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 10),
          child:InkWell(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            onTap: (){
              var state = Provider.of<FeedState>(context,listen: false);
              state.getpostDetailFromDatabase(key);
              Navigator.pushNamed(context, '/ImageViewPge');
            },
            child:Container(
              height: 190,
              width: fullWidth(context) *.8,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                image:DecorationImage(image: customAdvanceNetworkImage(_image),fit:BoxFit.cover)
              ),
            )
          )
      );
  }
  void addLikeToTweet(String postId){
      var state = Provider.of<FeedState>(context,);
      var authState = Provider.of<AuthState>(context,);
      state.addLikeToTweet(postId, authState.userId);
  }
  Widget _tweetBottpmIcon(){
    var feedstate = Provider.of<FeedState>(context,);
    var state = Provider.of<AuthState>(context,);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
      SizedBox(width: 80,),
        IconButton(
            onPressed: (){
              feedstate.setFeedModel = _model;
              Navigator.of(context).pushNamed('/FeedPostReplyPage/'+_model.key);
            },
           icon: customIcon(context,size: 20, icon:AppIcon.reply , istwitterIcon: true,),
          ),
       customText(_model.commentCount.toString()),
      SizedBox(width: 20,),
       IconButton(
            onPressed:(){addLikeToTweet(_model.key);},
            icon:  customIcon(context,size: 20, icon:AppIcon.retweet, istwitterIcon: true,),
       ),
        // customSwitcherWidget(
        //   duraton: Duration(milliseconds: 300),
        //   child: customText(_model.likeCount.toString(), key: ValueKey(_model.likeCount)),
        // ),
       SizedBox(width: 20,),
       IconButton(
            onPressed:(){addLikeToTweet(_model.key);},
            icon:  customIcon(context,size: 20, icon:_model.likeList.any((x)=>x.userId == state.userId) ? AppIcon.heartFill : AppIcon.heartEmpty, istwitterIcon: true, iconColor: _model.likeList.any((x)=>x.userId == state.userId) ? Colors.red :Theme.of(context).textTheme.caption.color),
       ),
       customSwitcherWidget(
          duraton: Duration(milliseconds: 300),
          child: customText(_model.likeCount.toString(), key: ValueKey(_model.likeCount)),
        ),
       SizedBox(width: 20,),
       IconButton(
            onPressed:(){share('social.flutter.dev/feed/${_model.key}');},
            icon:  Icon( Icons.share,color:Theme.of(context).textTheme.caption.color,size:20),
          ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    _model = widget.model;
   var feedstate = Provider.of<FeedState>(context,);
    return InkWell(
      onTap: (){
           feedstate.setFeedModel = _model;
           Navigator.of(context).pushNamed('/FeedPostDetail/'+_model.key);
      },
      child: Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child:Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 10,),
              Container(
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: (){
                         Navigator.of(context).pushNamed('/ProfilePage/'+_model?.userId);
                      },
                      child: customImage(context, _model.profilePic),
                    ),
                  ),
              SizedBox(width: 20,),
              Container(
                width: fullWidth(context) - 80 ,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              customText(_model.name,style: titleStyle),
                              SizedBox(width: 5,),
                              customText('${_model.username}',style: userNameStyle),
                              SizedBox(width: 10,),
                              customText('- ${getChatTime(_model.createdAt)}',style: userNameStyle)
                            ],
                          ) 
                          ),
                      //  trailing ?? Container(),
                      ],
                    ),
                    UrlText(text: _model.description,style:TextStyle(color: Colors.black, fontWeight: FontWeight.w400),urlStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),),
                  ],
                ),
              ),
               SizedBox(width: 10,),
            ],
          )
        ),
        _tweetImage(_model.imagePath,_model.key),
        _tweetBottpmIcon(),
        Divider(height: 0,)
      ],
    )
   );
  }
}