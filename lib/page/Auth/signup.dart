import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget{
  final VoidCallback loginCallback;

  const Signup({Key key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignupState();

}

class _SignupState extends State<Signup>{

  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _mobileController;
  TextEditingController _passwordController;
  TextEditingController _confirmController;
  TextEditingController _userNameController;
  final _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
 @override
  void initState() {
    _nameController = TextEditingController();
    _userNameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    // _emailController.text = 'bruce.wayne@gmail.com';
    // _passwordController.text = '1234567';
    // _nameController.text = 'Bruce Wayne';
    // _mobileController.text =    '9871234567';
    // _passwordController.text = '1234567';
    // _confirmController.text = '1234567';
    super.initState();
  }
  Widget _labelButton(String title,{Function onPressed}){
    return FlatButton(
      onPressed: (){ if(onPressed != null){onPressed();}},
      splashColor: Colors.grey.shade200,
      child: Text(title,style: TextStyle(color: Colors.black54),),
    );
  }
  Widget _body(BuildContext context){
  return Container(
    height: fullHeight(context) - 88,
    padding: EdgeInsets.symmetric(horizontal: 30),
      child:Form(
        key: _formKey,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _entryFeild('Name',controller: _nameController),
          // _entryFeild('Unique user name',controller: _userNameController),
          _entryFeild('Enter email',controller: _emailController),
          _entryFeild('Mobile no',controller: _mobileController),
          _entryFeild('Enter password',controller: _passwordController,isPassword:true),
          _entryFeild('Confirm password',controller: _confirmController,isPassword:true),
          _submitButton(context),
          _labelButton('Sign in',
            onPressed: (){
              var state = Provider.of<AuthState>(context,listen: false);
              state.logoutCallback();
            }
           )
      ],),
      )
  );
}
  Widget _entryFeild(String hint,{TextEditingController controller,bool isPassword = false}){
  return Container(
    margin: EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(30)
    ),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontStyle: FontStyle.normal,fontWeight: FontWeight.normal),
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,

        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.blue)),
        // filled: true,
        contentPadding:EdgeInsets.symmetric(vertical: 15,horizontal: 10)
      ),
    ),
  );
}
  Widget _submitButton(BuildContext context){
  return Container(
    margin: EdgeInsets.symmetric(vertical: 15),
    width: MediaQuery.of(context).size.width,
    child: FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      color: Colors.blueAccent,
      onPressed: _submitForm,
      padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
      child: Text('Sign up',style:TextStyle(color: Colors.white)),
    )
  );
}
 void _submitForm(){
   if(_emailController.text == null || _emailController.text.isEmpty || _passwordController.text == null || _passwordController.text.isEmpty || _confirmController.text == null ){
     customSnackBar(_scaffoldKey,'Please fill form carefully');
     return;
   }
   else if(_passwordController.text != _confirmController.text ){
     customSnackBar(_scaffoldKey,'Password and confirm password did not match');
     return;
   }
    var state = Provider.of<AuthState>(context,listen: false);
    Random random = new Random();
    int randomNumber = random.nextInt(8);

    User user = User(
      email:_emailController.text.toLowerCase(),
      bio: 'Edit profile to update bio',
      contact:  _mobileController.text,
      displayName: _nameController.text,
      dob:  DateTime(1950,DateTime.now().month,DateTime.now().day+3).toString(),
      location: 'Somewhere in universe',
      profilePic: dummyProfilePicList[randomNumber],
      isVerified: false
       );
    state.signUp(user,password: _passwordController.text,scaffoldKey: _scaffoldKey).then((status)=>{
          print(status),
    }).whenComplete((){
       if(state.authStatus == AuthStatus.LOGGED_IN){
           widget.loginCallback();
       }
    });
 }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: customText('Sign Up',context: context,style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(child :_body(context)),
    );
  }
  
}