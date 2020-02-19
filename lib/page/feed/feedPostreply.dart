import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class FeedPostReplyPage extends StatefulWidget {
  FeedPostReplyPage({Key key,this.postId}) : super(key: key);
  final String postId;
  _FeedPostReplyPageState createState() => _FeedPostReplyPageState();
}

class _FeedPostReplyPageState extends State<FeedPostReplyPage> {
 TextEditingController _textEditingController;
 ScrollController scrollcontroller;
 bool isScrollingDown = false;
 String postId;
  @override
  void initState() { 
    postId = widget.postId;
     scrollcontroller = ScrollController();
    _textEditingController = TextEditingController();
     scrollcontroller
     
     ..addListener(_scrollListener);
    super.initState();
    
  }
 @override
  void dispose() {
    scrollcontroller.dispose();
    super.dispose();
  }
 _scrollListener() {
   
      if (scrollcontroller.position.userScrollDirection == ScrollDirection.reverse) {
      if (!isScrollingDown) {
        setState(() {
           isScrollingDown = true;
          //  scrollcontroller.animateTo(scrollcontroller.position.maxScrollExtent,
          //   duration: Duration(milliseconds: 300), curve: Curves.ease);
        });
      }
    }
    if (scrollcontroller.position.userScrollDirection ==ScrollDirection.forward) {
      setState(() {
        isScrollingDown = false;
        scrollcontroller.animateTo(scrollcontroller.position.minScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      });
      
    }
    // if (scrollcontroller.offset >= scrollcontroller.position.maxScrollExtent &&
    //   !scrollcontroller.position.outOfRange) {
    //   cprint("List reach the bottom");
    //   }
    // if (scrollcontroller.offset <= scrollcontroller.position.minScrollExtent &&
    //     !scrollcontroller.position.outOfRange) {
    //    cprint("List reach the top");
    // }
 }
  Widget _descriptionEntry(){
     return TextField(
       controller: _textEditingController,
       onChanged: (text){
         setState(() {});
       },
       maxLines: null,
       decoration: InputDecoration(
         border: InputBorder.none,
         hintText: 'Tweet your reply',
         hintStyle: TextStyle(fontSize: 18)
       ),
     );
  }
  Widget _postCard(){
      var feedState = Provider.of<FeedState>(context,);
    var model = feedState.feedModel;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize:MainAxisSize.min,
      children: <Widget>[
        Stack(
          children: <Widget>[
             Container(
             padding: EdgeInsets.only(left: 40),
             margin: EdgeInsets.only(left: 20,top: 20,bottom: 3),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(width: 2.0, color:  Colors.grey.shade400,),),
              ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
               Container(
                 width:fullWidth(context) - 82,
                 child: UrlText(text: model.description,style:TextStyle(color: Colors.black, fontWeight: FontWeight.w400),urlStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),),
               ),
               SizedBox(height: 30,),
               UrlText(text: 'Replying to ${model.user.userName ?? model.user.displayName}',style: TextStyle(color: TwitterColor.paleSky,fontSize: 13,)),
             ],)
           ),
           Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
               customImage(context, model.user.profilePic),
               SizedBox(width: 10,),
               customText(model.user.displayName,style: titleStyle),
               SizedBox(width: 10,),
               customText( model.user.userName,style: TextStyle(color: TwitterColor.paleSky,fontSize: 17,fontWeight: FontWeight.w500,)),
               SizedBox(width: 10,),
               customText('- ${getChatTime(model.createdAt)}',style: subtitleStyle)
             ],
           ),
          ],
         ),
        
       ],
    );
  }
  void _submitButton(){
     var state = Provider.of<FeedState>(context,);
     var authState = Provider.of<AuthState>(context,);
     var user = authState.user;
     var profilePic = user.photoUrl ?? dummyProfilePic ;
     var tags = getHashTags(_textEditingController.text);
     var commentedUser = User(displayName: user.displayName ?? user.email.split('@')[0],profilePic: profilePic,userId: user.uid,userName: authState.userModel.userName);
     state.addcommentToPost(postId,userId:authState.user.uid,comment: _textEditingController.text,user: commentedUser,tags: tags);
    Navigator.pop(context);
  }
 
 
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context,);
    return Scaffold(
      appBar: CustomAppBar(
        title: customTitleText('',),
        onActionPressed: _submitButton,
        isCrossButton :true,
         submitButtonText:'Reply',
         isSubmitDisable: _textEditingController.text == null || _textEditingController.text.isEmpty,
         isbootomLine: isScrollingDown,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body:SingleChildScrollView(
        controller: scrollcontroller,
        child:  Container(
          height: fullHeight(context),
         padding: EdgeInsets.only(left: 10,right: 10,bottom: 10),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: <Widget>[ 
             _postCard(),
              Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 customImage(context, state.user?.photoUrl, height: 40),
                 SizedBox(width: 20,),
                 Expanded(
                   child: _descriptionEntry(),
                 )
               ],
             ),
            //  Divider(),
             Expanded(child: Container(),)
           ],
         ),
       ),
      )
    );
  }
}