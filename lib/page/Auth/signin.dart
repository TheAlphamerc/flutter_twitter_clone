import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';
class SignIn extends StatefulWidget{
  final VoidCallback loginCallback;

  const SignIn({Key key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignInState();

}

class _SignInState extends State<SignIn>{

  TextEditingController _emailController;
  TextEditingController _passwordController;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() { 
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // _emailController.text = 'sonu.sharma@kritivity.com';
    // _passwordController.text = '1234567';
    super.initState();
  }
  
  Widget _body(BuildContext context){
  return SingleChildScrollView(
    child: Container(
    padding: EdgeInsets.symmetric(horizontal: 30),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 150,),
          _entryFeild('Enter email',controller: _emailController),
          _entryFeild('Enter password',controller: _passwordController,isPassword:true),
          // _submitButton(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _emailLoginButton(context),
              _googleLoginButton(context)
            ],
          ),
          _labelButton('Forget password?',onPressed: (){
            Navigator.of(context).pushNamed('/ForgetPasswordPage');
          }),
          SizedBox(height: 100,),
          _labelButton('Create new account',onPressed: _createAccount),
      ],)
  ),
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
        onPressed: (){
          Navigator.of(context).pushNamed('/SearchPage');
        },
        padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
        child: Text('Sign in',style:TextStyle(color: Colors.white)),
      )
    );
  }
  Widget _labelButton(String title,{Function onPressed}){
    return FlatButton(
      onPressed: (){ if(onPressed != null){onPressed();}},
      splashColor: Colors.grey.shade200,
      child: Text(title,style: TextStyle(color: Colors.black54),),
    );
  }
  Widget _emailLoginButton(BuildContext context){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 35),
      // width: MediaQuery.of(context).size.width,
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.blueAccent,
        onPressed: (){
          var state = Provider.of<AuthState>(context,listen: false);
          state.signIn(_emailController.text,_passwordController.text,scaffoldKey: _scaffoldKey).then((status)=>{
               if(state.userModel != null){
                 widget.loginCallback()
               }
          });
        },
        padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
        child: Text('Email Login',style:TextStyle(color: Colors.white)),
      )
    );
  }
  Widget _googleLoginButton(BuildContext context){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 35),
      // width: MediaQuery.of(context).size.width,
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.blueAccent,
        onPressed: (){
          var state = Provider.of<AuthState>(context,listen: false);
          state.handleGoogleSignIn().then((status)=>{
                // print(status)
          });
          // widget.loginCallback();
        },
        padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
        child: Text('Google Login',style:TextStyle(color: Colors.white)),
      )
    );
  }
  void _createAccount(){
     var state = Provider.of<AuthState>(context,listen: false);
     state.openSignUpPage();
    // Navigator.of(context).pushNamed('/SignUp');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: customText('Sign in',context: context,style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
  
}