// import 'package:fancy_bottom_navigation/internal/tab_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/bottomMenuBar/tabItem.dart';
import 'package:provider/provider.dart';
import '../customWidgets.dart';
// import 'customBottomNavigationBar.dart';

class BottomMenubar extends StatefulWidget{
  const BottomMenubar({this.pageController});
  final PageController pageController;
  _BottomMenubarState createState() => _BottomMenubarState();
}
class _BottomMenubarState extends State<BottomMenubar>{
  PageController _pageController;
  int _selectedIcon = 0;
  @override
  void initState() { 
    _pageController = widget.pageController;
    super.initState();
    
  }
  Widget _iconRow(){
    return Container(
      height: 50,
      decoration: BoxDecoration(color: Theme.of(context).bottomAppBarColor, boxShadow: [
            BoxShadow(
                color: Colors.black12, offset: Offset(0,-.1), blurRadius: 0)
          ]),
      child:  Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _icon(Icons.home,0),
                  _icon(Icons.search,1),
                  _icon(Icons.mail_outline,2,),
                ],
              ),
    );
  }
  Widget _icon(IconData iconData,int index,{bool isCustomIcon = false,int icon}){
    var state = Provider.of<AppState>(context,);
    return Expanded(
      child:  Container(
            height: double.infinity,
            width: double.infinity,
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              curve: Curves.easeIn,
              alignment: Alignment(0,  ICON_ON),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: ANIM_DURATION),
                opacity:  ALPHA_ON,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  padding: EdgeInsets.all(0),
                  alignment: Alignment(0, 0),
                  icon: isCustomIcon ? customIcon(context,icon:icon,size: 22) :
                  Icon(iconData,
                   color:index == state.pageIndex ? Theme.of(context).primaryColor: Theme.of(context).textTheme.caption.color,
                  ),
                  onPressed: () {
                      setState(() {
                        _selectedIcon = index;
                        state.setpageIndex = index;
                      });
                      //  _pageController.animateToPage(
                      //   index,
                      //   duration: const Duration(milliseconds: 500),
                      //   curve: Curves.ease,
                      // );
                  },
                ),
              ),
            ),
          ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
     return _iconRow();
   }
}