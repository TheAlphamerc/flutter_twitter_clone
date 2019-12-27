import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:provider/provider.dart';

import 'customWidgets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final Widget leading;
  final Widget title;
  final List<Widget> actions;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function onActionPressed;
  final TextEditingController textController;
  final int icon;
  final bool isBackButton;
  final bool isCrossButton;
  final String submitButtonText;
  final bool isSubmitDisable;
  final bool isbootomLine ;
  Size appBarHeight = Size.fromHeight(60.0);
  @override
  Size get preferredSize => appBarHeight;
   CustomAppBar({Key key, this.leading, this.title, this.actions, this.scaffoldKey,this.icon,this.onActionPressed,this.textController,this.isBackButton = false,this.isCrossButton = false,this.submitButtonText,this.isSubmitDisable = true,this.isbootomLine = true}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return AppBar(
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        leading: isBackButton ? BackButton()
        : isCrossButton ? IconButton(
          icon: Icon(Icons.close),
          onPressed: (){Navigator.pop(context);},
        )
        : Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.all(10),
              child: customInkWell(
                context: context,
                function2: (){scaffoldKey.currentState.openDrawer();},
                child: customImage(context, authState.userModel?.photoUrl,height: 30)
              ),
            );
          },
        ),
        title: title != null ? title
        : TextField(
            controller:textController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search..',
              contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.blue)),
            ),
        ),
        actions: <Widget>[
          submitButtonText != null ?
          Padding(
            padding: EdgeInsets.symmetric(horizontal:10,vertical: 12),
            child: customInkWell(
            context: context,
            radius: BorderRadius.circular(40),
            function2: (){if(onActionPressed!=null) onActionPressed();},
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal:20,vertical: 0),
              decoration: BoxDecoration(
                color: !isSubmitDisable ? Theme.of(context).primaryColor: Theme.of(context).primaryColor.withAlpha(150),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(submitButtonText,style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
            )
          ),
          )
          : icon == null ? Container()
          : IconButton(
            onPressed: (){if(onActionPressed!=null) onActionPressed();},
            icon: customIcon(context,icon:icon,istwitterIcon: true),
          )
        ],
        bottom: PreferredSize(child: Container(color:  isbootomLine ? Colors.grey.shade200 : Theme.of(context).backgroundColor, height:1.0 ,), preferredSize: Size.fromHeight(0.0))
      );
  }
 
}