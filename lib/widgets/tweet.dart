import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/page/feed/widgets/tweetIconsRow.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:provider/provider.dart';

import 'customWidgets.dart';
import 'newWidget/customUrlText.dart';

class Tweet extends StatefulWidget {
  final FeedModel model;
  final bool isTweetDetail;
  final Widget trailing;
  final TweetType type;
  const Tweet({Key key, this.model, this.isTweetDetail = false, this.trailing, this.type = TweetType.Tweet}) : super(key: key);
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
  
  @override
  Widget build(BuildContext context) {
    _model = widget.model;
   var feedstate = Provider.of<FeedState>(context,);
    return InkWell(
      onTap: (){
            if(widget.isTweetDetail || widget.type == TweetType.Reply ){
              return;
            }
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
                      child: customImage(context, _model.user.profilePic),
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
                              customText(_model.user.displayName,style: titleStyle),
                              SizedBox(width: 3,),
                              _model.isVerifiedUser ?
                              customIcon(context,icon:AppIcon.blueTick, istwitterIcon: true,iconColor:  AppColor.primary, size:13,paddingIcon:3)
                              :SizedBox(),
                              SizedBox(width: 5,),
                              customText('${_model.user.userName}',style: userNameStyle),
                              SizedBox(width: 10,),
                              customText('- ${getChatTime(_model.createdAt)}',style: userNameStyle),
                              Expanded(
                                child: SizedBox()
                              ),
                              Container(
                                  child: widget.trailing == null ? SizedBox()
                                  : widget.trailing
                                ),
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
        Padding(
          padding: EdgeInsets.only(left: widget.isTweetDetail ? 10 : 60),
          child:TweetIconsRow(
            type: widget.type,
            model:_model,
            isTweetDetail:widget.isTweetDetail,
            iconColor: Theme.of(context).textTheme.caption.color,
            iconEnableColor: TwitterColor.ceriseRed,
            size: 20,),
        ),
        Divider(height: 0,)
      ],
    )
   );
  }
}