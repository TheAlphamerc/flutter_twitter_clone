// import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class SidebarMenu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey ;

  const SidebarMenu({Key key, this.scaffoldKey}) : super(key: key);//= new GlobalKey<ScaffoldState>();
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  int myId;
  @override
  void initState() {
    
    super.initState();
  }

  Widget _menuHeader() {
    final state = Provider.of<AuthState>(context);
    if(state.userModel == null){
      return customInkWell(
          context: context, 
          function2: (){
              //  Navigator.of(context).pushNamed('/signIn');
            },
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 200,minHeight: 100),
            child: Center(child: Text('Login to continue',style: onPrimaryTitleText,),)
          ),
        );
    }
   else{
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
            ListTile(
              onTap: (){
                Navigator.of(context).pushNamed('/ProfilePage');
              },
              leading: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  border: Border.all(color:Colors.white,width:2),
                    borderRadius: BorderRadius.circular(28),
                    image: DecorationImage(image: customAdvanceNetworkImage(state.userModel.photoUrl ?? dummyProfilePic,),fit:BoxFit.cover)
                )
              ),
              title: customText(
                state.userModel.displayName ?? state.userModel.email.split('.')[0],
                style: onPrimaryTitleText.copyWith(color: Colors.black),
              ),
              subtitle: customText(
                state.userModel.userName,
                style: onPrimarySubTitleText.copyWith(color: Colors.black54),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              alignment: Alignment.center,
              child:Row(
                children: <Widget>[
                SizedBox(width: 40,),
                customText(state.userModel.followers.toString() ?? '0',style:TextStyle(fontWeight: FontWeight.bold,fontSize:17)),
                customText(' Followors',style:TextStyle(color: Colors.black54,fontSize:17)),
                SizedBox(width: 10,),
                customText(state.userModel.following.toString()?? '0',style:TextStyle(fontWeight: FontWeight.bold,fontSize:17)),
                customText(' Following',style:TextStyle(color: Colors.black54,fontSize:17)),
              ],)
            )
         ],
       )
     );
   }
 }
 ListTile _menuListRowButton(String title,{Function onPressed,IconData icon}) {
    return ListTile(
       onTap: (){
            if(onPressed != null){
              onPressed();
            }
          },
        leading: Padding(
          padding: EdgeInsets.only(top: 5),
          child:Icon(icon),
        ),
        title:customText(title),
    );
  }
 void _logOut(){
   final state = Provider.of<AuthState>(context);
   state.logoutCallback();
 }
dispose() {
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
            children: <Widget>[
              Container(
                height: 150,
                child: _menuHeader(),
              ),
            Divider(),
            _menuListRowButton('Profile',icon: Icons.verified_user,onPressed: (){Navigator.of(context).pushNamed('/ProfilePage');}),
            _menuListRowButton('Lists',icon: Icons.list),
            _menuListRowButton('Settings',icon: Icons.settings),
            _menuListRowButton('Help Center',icon: Icons.help),
            Divider(),
            _menuListRowButton('Logout',onPressed: _logOut,icon: Icons.block,)
          ],
        ),  
    ));
  }
}
