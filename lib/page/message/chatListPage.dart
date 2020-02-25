import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/page/common/sidebar.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/chats/chatState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class ChatListPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ChatListPage({Key key, this.scaffoldKey}) : super(key: key);
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  @override
  void initState() {
    final chatState = Provider.of<ChatState>(context,listen: false);
    final state = Provider.of<AuthState>(context,listen: false);
    chatState.setIsChatScreenOpen = true;
    
    // chatState.databaseInit(state.profileUserModel.userId,state.userId);
    chatState.getUserchatList(state.user.uid);
    super.initState();
    
  }

  Widget _body(){
      final state = Provider.of<ChatState>(context,);
      if(state.chatUserList == null){
        return Center(child:Text('No chat available!!',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),);
      }
      else{
       return ListView.separated(
         itemCount: state.chatUserList.length,
         itemBuilder: (context,index) => _userCard(state.chatUserList[index]),
         separatorBuilder: (context, index){
           return Divider(height: 0,);
         },
        );
      }
  }
 Widget _userCard(User model){
   return Container(
     color: TwitterColor.mystic,
     child: ListTile(
       onTap: (){
         Navigator.of(context).pushNamed('/ProfilePage/${model.userId}');
       },
       leading: GestureDetector(
         onTap: (){ Navigator.of(context).pushNamed('/ProfilePage/${model.userId}');},
         child:  Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            border: Border.all(color:Colors.white,width:2),
              borderRadius: BorderRadius.circular(28),
              image: DecorationImage(image: customAdvanceNetworkImage(model.profilePic ?? dummyProfilePic,),fit:BoxFit.cover)
          )
        ),
       ),
       title: customText(
         model.displayName ?? (model.email == null ? '' : model.email.split('.')[0]),
         style: onPrimaryTitleText.copyWith(color: Colors.black),
       ),
       subtitle: customText(
         '@${model.displayName}',
         style: onPrimarySubTitleText.copyWith(color: Colors.black54),
       ),
     ),
   );
 }
 void onSettingIconPressed(){
      cprint('Settings');
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(scaffoldKey: widget.scaffoldKey,title: customTitleText('Messages',),icon:AppIcon.settings,onActionPressed: onSettingIconPressed,),
      backgroundColor: Theme.of(context).backgroundColor,
      body:_body()
    );
  }
}