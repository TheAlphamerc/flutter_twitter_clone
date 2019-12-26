import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customProgressbar.dart';
import 'package:provider/provider.dart';
class SearchPage extends StatefulWidget{
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SearchPage({Key key, this.scaffoldKey}) : super(key: key);
    @override
    State<StatefulWidget> createState() => _SearchPageState();

  }

  class _SearchPageState extends State<SearchPage>{
    TextEditingController textController;
    @override
    void initState() { 
      textController = TextEditingController();
       var state = Provider.of<AuthState>(context,listen: false);
     super.initState();
    }
   
    
    void onSearch(){
      cprint('Search');
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar:CustomAppBar(scaffoldKey: widget.scaffoldKey,textController:textController,icon:Icons.search,onActionPressed: onSearch,),
        body: Container()
      );
    }
    
  }
