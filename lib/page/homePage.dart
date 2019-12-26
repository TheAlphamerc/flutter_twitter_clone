import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/page/feed/feedPage.dart';
import 'package:flutter_twitter_clone/page/message/chatListPage.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:flutter_twitter_clone/widgets/bottomMenuBar/bottomMenuBar.dart';
import 'package:provider/provider.dart';
import 'SearchPage.dart';
import 'common/sidebar.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int pageIndex = 0;
  @override
  void initState() {
    var state = Provider.of<AppState>(context,listen: false);
    state.setpageIndex = 0;
    super.initState();
  }
  Widget _body(){
    var state = Provider.of<AppState>(context);
    return Container(
      child: _getPage(state.pageIndex) 
    );
  }
  Widget _getPage(int index){
    switch (index) {
      case 0: return FeedPage(scaffoldKey: _scaffoldKey,); break;
      case 1: return SearchPage(scaffoldKey: _scaffoldKey); break;
      case 2: return ChatListPage(scaffoldKey: _scaffoldKey); break;
        default: return FeedPage(scaffoldKey: _scaffoldKey); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomMenubar(),
      drawer: SidebarMenu(),
      body: _body()
   );
  }
}