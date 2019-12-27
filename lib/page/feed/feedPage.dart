import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/page/common/sidebar.dart';
import 'package:flutter_twitter_clone/page/feed/createFeed.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  
  final GlobalKey<ScaffoldState> scaffoldKey;
  const FeedPage({Key key, this.scaffoldKey}) : super(key: key);_FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  @override
  void initState() { 
    super.initState();
    var state = Provider.of<FeedState>(context,listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }
  Widget _floatingActionButton(){
    return FloatingActionButton(
      onPressed: (){
         Navigator.of(context).pushNamed('/CreateFeedPage');
       },
      child: Icon(Icons.add,),
    );
  }
  Widget _body(){
      var state = Provider.of<FeedState>(context,);
      if(state.isBusy && state.feedlist == null){
        return loader();
      }
      else if(!state.isBusy && state.feedlist == null){
        return EmptyListWidget(
            title:'No Feed',
            subTitle: 'Seems like no feed available yet',
            packageImage: PackageImage.Image_2,
          );
      }
      else{
        return ListView.builder(
          itemCount: state.feedlist.length,
          itemBuilder: (context,index) => _postCard(state.feedlist[index],feedstate: state),
        );
      }
  }
  Widget _postCard(FeedModel model,{FeedState feedstate}){
    var state = Provider.of<AuthState>(context,);
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor
          ),
          child: customListTile(
            context,
            onTap: (){
               Navigator.of(context).pushNamed('/FeedPostDetail/'+model.key);
            },
            leading: customInkWell(
              context:context,
              function2:(){
                Navigator.of(context).pushNamed('/ProfilePage/'+model?.userId);
              },
              child:customImage(context, model.profilePic)
            ),
            title: Row(
              children: <Widget>[
                customText(model.name,style: titleStyle),
                SizedBox(width: 10,),
                customText('- ${getChatTime(model.createdAt)}',style: subtitleStyle)
              ],
            ),
            subtitle: UrlText(text: model.description,style:TextStyle(color: Colors.black, fontWeight: FontWeight.w400),urlStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),),
          )
        ),
        _imageFeed(model.imagePath,model.key),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          SizedBox(width: 80,),
            IconButton(
                onPressed: (){
                  feedstate.setFeedModel = model;
                  Navigator.of(context).pushNamed('/FeedPostReplyPage/'+model.key);
                },
                icon:  Icon(Icons.message,color :  Colors.black38,),
              ),
            customText(model.commentCount.toString()),
           
           SizedBox(width: 20,),
           IconButton(
                onPressed:(){addLikeToPost(model.key);},
                icon:  Icon( model.likeList.any((x)=>x.userId == state.userId) ? Icons.favorite : Icons.favorite_border,color: model.likeList.any((x)=>x.userId == state.userId) ? Colors.red : Colors.black38),
           ),
           customSwitcherWidget(
              duraton: Duration(milliseconds: 300),
              child: customText(model.likeCount.toString(), key: ValueKey(model.likeCount)),
            ),
           SizedBox(width: 20,),
           IconButton(
                onPressed:(){share('social.flutter.dev/feed/${model.key}');},
                icon:  Icon( Icons.share,color:Colors.black38),
              ),
          ],
        ),
        Divider(height: 0,)
      ],
    );
  }
   Widget _imageFeed(String _image,String key){
     return _image == null ? Container() :
     customInkWell(
       context: context,
       function2: (){ 
         var state = Provider.of<FeedState>(context,listen: false);
          state.getpostDetailFromDatabase(key);
          Navigator.pushNamed(context, '/ImageViewPge');
        //  Navigator.of(context).pushNamed('/FeedPostDetail/'+key);
         },
       child:Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 10),
          child:Container(
          height: 190,
          width: fullWidth(context) *.8,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            image:DecorationImage(image: customAdvanceNetworkImage(_image),fit:BoxFit.cover)
          ),
          // child: Image.file(_image),
        )
      )
     );
      
   }
  void addLikeToPost(String postId){
      var state = Provider.of<FeedState>(context,);
      var authState = Provider.of<AuthState>(context,);
      state.addLikeToPost(postId, authState.userId);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingActionButton(),
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: CustomAppBar(scaffoldKey: widget.scaffoldKey,title: customTitleText('Home',),),
      body: Container(
        height: fullHeight(context),
        width: fullWidth(context),
        child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: ()async{
          var state = Provider.of<FeedState>(context,);
            state.getDataFromDatabase();
            return Future.value(true);
        },
        child:  _body(),)
      ),
    );
  }
}