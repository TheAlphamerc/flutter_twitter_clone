import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/chatModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/chats/chatState.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/rippleButton.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class ChatListPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ChatListPage({Key key, this.scaffoldKey}) : super(key: key);
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    chatState.setIsChatScreenOpen = true;

    // chatState.databaseInit(state.profileUserModel.userId,state.userId);
    chatState.getUserchatList(state.user.uid);
    super.initState();
  }

  Widget _body() {
    final state = Provider.of<ChatState>(context);
    final searchState = Provider.of<SearchState>(context, listen: false);
    if (state.chatUserList == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'No message available ',
          subTitle:
              'When someone sends you message,UserModel list\'ll show up here \n  To send message tap message button.',
        ),
      );
    } else {
      if (searchState.userList.isEmpty) {
        searchState.resetFilterList();
      }
      return ListView.separated(
        physics: BouncingScrollPhysics(),
        itemCount: state.chatUserList.length,
        itemBuilder: (context, index) => _userCard(
            searchState.userlist.firstWhere(
              (x) => x.userId == state.chatUserList[index].key,
              orElse: () => UserModel(userName: "Unknown"),
            ),
            state.chatUserList[index]),
        separatorBuilder: (context, index) {
          return Divider(
            height: 0,
          );
        },
      );
    }
  }

  Widget _userCard(UserModel model, ChatMessage lastMessage) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        onTap: () {
          final chatState = Provider.of<ChatState>(context, listen: false);
          final searchState = Provider.of<SearchState>(context, listen: false);
          chatState.setChatUser = model;
          if (searchState.userlist.any((x) => x.userId == model.userId)) {
            chatState.setChatUser = searchState.userlist
                .where((x) => x.userId == model.userId)
                .first;
          }
          Navigator.pushNamed(context, '/ChatScreenPage');
        },
        leading: RippleButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/ProfilePage/${model.userId}');
          },
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(28),
              image: DecorationImage(
                  image: customAdvanceNetworkImage(
                    model.profilePic ?? dummyProfilePic,
                  ),
                  fit: BoxFit.cover),
            ),
          ),
        ),
        title: TitleText(
          model.displayName ?? "NA",
          fontSize: 16,
          fontWeight: FontWeight.w800,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: customText(
          getLastMessage(lastMessage.message) ?? '@${model.displayName}',
          style: onPrimarySubTitleText.copyWith(color: Colors.black54),
        ),
        trailing: lastMessage == null
            ? SizedBox.shrink()
            : Text(
                getChatTime(lastMessage.createdAt).toString(),
              ),
      ),
    );
  }

  FloatingActionButton _newMessageButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/NewMessagePage');
      },
      child: customIcon(
        context,
        icon: AppIcon.newMessage,
        istwitterIcon: true,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/DirectMessagesPage');
  }

  String getLastMessage(String message) {
    if (message != null && message.isNotEmpty) {
      if (message.length > 100) {
        message = message.substring(0, 80) + '...';
        return message;
      } else {
        return message;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: customTitleText(
          'Messages',
        ),
        icon: AppIcon.settings,
        onActionPressed: onSettingIconPressed,
      ),
      floatingActionButton: _newMessageButton(),
      backgroundColor: TwitterColor.mystic,
      body: _body(),
    );
  }
}
