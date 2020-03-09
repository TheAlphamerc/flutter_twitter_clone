import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/chatModel.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/chats/chatState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class ChatScreenPage extends StatefulWidget {
  ChatScreenPage({Key key,this.userProfileId}) : super(key: key);
  final String userProfileId;
  _ChatScreenPageState createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  final messageController = new TextEditingController();
  String senderId;

  ScrollController _controller;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = ScrollController();
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    chatState.setIsChatScreenOpen = true;
    senderId = state.userId;
    chatState.databaseInit(chatState.chatUser.userId, state.userId);
    chatState.getchatDetailAsync();
    super.initState();
  }

  Widget _chatScreenBody() {
    final state = Provider.of<ChatState>(context);
    if (state.messageList == null || state.messageList.length == 0) {
      return Center(
        child: Text(
          'No message found',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ); //EmptyListWidget('No chat available',subTitle: 'You can start new chat',image: 'im_emptyIcon_3.png');
    }
    return ListView.builder(
      controller: _controller,
      shrinkWrap: true,
      reverse: true,
      physics: BouncingScrollPhysics(),
      itemCount: state.messageList.length,
      itemBuilder: (context, index) => chatMessage(state.messageList[index]),
    );
  }

  Widget chatMessage(ChatMessage message) {
    if (senderId == null) {
      return Container();
    }
    if (message.senderId == senderId)
      return _outGoingMessage(message);
    else
      return _incommingMessage(message);
  }

  Widget _outGoingMessage(ChatMessage chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Wrap(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: 10,
                top: 20,
                left: (fullWidth(context) / 4),
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  color: Colors.grey.shade200),
              child: Text(chat.message),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            getChatTime(chat.createdAt),
            style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12),
          ),
        )
      ],
    );
  }

  Widget _incommingMessage(ChatMessage chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Wrap(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                left: 10,
                top: 20,
                right: (fullWidth(context) / 4),
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  color: Colors.grey.shade200),
              child: Text(chat.message),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 14),
          child: Text(
            getChatTime(chat.createdAt),
            style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12),
          ),
        )
      ],
    );
  }

  Widget _bottomEntryField() {
    final state = Provider.of<ChatState>(context, listen: false);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Divider(
            thickness: 0,
            height: 1,
          ),
          TextField(
            onSubmitted: (val) async {
              submitMessage();
            },
            controller: messageController,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 13),
              alignLabelWithHint: true,
              hintText: 'Start with a message...',
              suffixIcon:
                  IconButton(icon: Icon(Icons.send), onPressed: submitMessage),
              // fillColor: Colors.black12, filled: true
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final chatState = Provider.of<ChatState>(context);
    chatState.setIsChatScreenOpen = false;
    chatState.dispose();
    return true;
  }

  void submitMessage() {
    var state = Provider.of<ChatState>(context, listen: false);
    var authstate = Provider.of<AuthState>(context, listen: false);
    ChatMessage message;
    message = ChatMessage(
        message: messageController.text,
        createdAt: DateTime.now().toIso8601String(),
        senderId: authstate.user.uid,
        receiverId: authstate.profileUserModel.userId,
        seen: false,
        timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: authstate.user.displayName);
    if (messageController.text == null || messageController.text.isEmpty) {
      return;
    }
    User myUser = User(
        displayName: authstate.user.displayName,
        userId: authstate.user.uid,
        profilePic: authstate.user.photoUrl);
    state.onMessageSubmitted(message,
        myUser: myUser, secondUser: authstate.profileUserModel);
    messageController.text = '';
    _controller.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<ChatState>(context, listen: false);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              UrlText(
                text: state.chatUser.displayName,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                state.chatUser.userName,
                style: TextStyle(color: AppColor.darkGrey, fontSize: 15),
              )
            ],
          ),
          iconTheme: IconThemeData(color: Colors.blue),
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.info, color:AppColor.primary), onPressed: (){

            })
          ],
        ),
        body: Stack(
          children: <Widget>[
            Align(
              alignment:Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: _chatScreenBody(),
              ),
            ),
            _bottomEntryField()
          ],
        ),
      ),
    );
  }
}
