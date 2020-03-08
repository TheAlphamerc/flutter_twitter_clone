import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class SidebarMenu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey ;

  const SidebarMenu({Key key, this.scaffoldKey}) : super(key: key);//= new GlobalKey<ScaffoldState>();
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  int myId;

  Widget _menuHeader() {
    final state = Provider.of<AuthState>(context);
    if(state.userModel == null){
      return customInkWell(
          context: context, 
          onPressed: (){
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
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
            Container(
                height: 56,
                width: 56,
                margin:EdgeInsets.only(left:17,top:10),
                decoration: BoxDecoration(
                  border: Border.all(color:Colors.white,width:2),
                    borderRadius: BorderRadius.circular(28),
                    image: DecorationImage(image: customAdvanceNetworkImage(state.userModel.profilePic ?? dummyProfilePic,),fit:BoxFit.cover)
                )
              ),
            ListTile(
              onTap: (){
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/ProfilePage');
              },
                title:Row(
              children: <Widget>[
                UrlText(
                  text: state.userModel.displayName ?? state.userModel.email.split('.')[0],
                  style: onPrimaryTitleText.copyWith(color: Colors.black,fontSize: 20),
                ),
                SizedBox(
                  width: 3,
                ),
                state.userModel.isVerified
                    ? customIcon(context,
                        icon: AppIcon.blueTick,
                        istwitterIcon: true,
                        iconColor: AppColor.primary,
                        size: 18,
                        paddingIcon: 3)
                    : SizedBox(
                        width: 0,
                      ),
              ],
            ),
              //    customText(
              //   state.userModel.displayName ?? state.userModel.email.split('.')[0],
              //   style: onPrimaryTitleText.copyWith(color: Colors.black,fontSize: 20),
              // ),
              subtitle: customText(
                state.userModel.userName,
                style: onPrimarySubTitleText.copyWith(color: Colors.black54,fontSize: 15),
              ),
              trailing: customIcon(context,icon:AppIcon.arrowDown, iconColor: AppColor.primary, paddingIcon: 20),
            ),
             Container(
              alignment: Alignment.center,
              child:Row(
                children: <Widget>[
                SizedBox(width: 17,),
                customText('${state.userModel.followers ?? 0 }',style:TextStyle(fontWeight: FontWeight.bold,fontSize:17)),
                customText(' Followors',style:TextStyle(color: Colors.black54,fontSize:17)),
                SizedBox(width: 10,),
                customText('${state.userModel.following ?? 0 }'?? '0',style:TextStyle(fontWeight: FontWeight.bold,fontSize:17)),
                customText(' Following',style:TextStyle(color: Colors.black54,fontSize:17)),
              ],)
            )
         ],
       )
     );
   }
 }
 ListTile _menuListRowButton(String title,{Function onPressed,int icon, bool isEnable = false}) {
    return ListTile(
       onTap: (){
            if(onPressed != null){
              onPressed();
            }
          },
        leading: Padding(
          padding: EdgeInsets.only(top: 5),
          child:icon == null ? SizedBox() : customIcon(context,icon: icon, size: 25 ,iconColor: isEnable ? AppColor.darkGrey : AppColor.lightGrey),
        ),
        title:customText(title,style: TextStyle(fontSize: 22, color: isEnable ? AppColor.secondary : AppColor.lightGrey)),
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
                height: 160,
                child: _menuHeader(),
              ),
            Divider(),
            _menuListRowButton('Profile',icon: AppIcon.profile,isEnable: true, onPressed: (){Navigator.of(context).pushNamed('/ProfilePage');}),
            _menuListRowButton('Lists',icon: AppIcon.lists),
            _menuListRowButton('Bookamrks',icon:AppIcon.bookmark),
            _menuListRowButton('Moments',icon: AppIcon.moments),
            _menuListRowButton('Twitter ads',icon: AppIcon.twitterAds),
            Divider(),
            _menuListRowButton('Settings and privacy',),
            _menuListRowButton('Help Center',),
            Divider(),
            _menuListRowButton('Logout',onPressed: _logOut,isEnable: true)
          ],
        ),  
    ));
  }
}
