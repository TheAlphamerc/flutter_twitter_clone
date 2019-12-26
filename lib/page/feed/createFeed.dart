import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class CreateFeedPage extends StatefulWidget {
  CreateFeedPage({Key key}) : super(key: key);
  _CreateFeedPageState createState() => _CreateFeedPageState();
}

class _CreateFeedPageState extends State<CreateFeedPage> {
  TextEditingController _textEditingController;
   File _image;
  @override
  void initState() { 
   initDatabase();

    _textEditingController = TextEditingController();
    super.initState();
  }
 
  void initDatabase()async{
    //  var state = Provider.of<FeedState>(context,listen: false);
    //  await state.databaseInit().then((value){
    //   if(value){
    //     cprint('database initilize');
    //   }
    // });
  }
   Widget _descriptionEntry(){
     return TextField(
       controller: _textEditingController,
       onChanged: (value){setState(() {
         
       });},
       maxLines: null,
       decoration: InputDecoration(
         border: InputBorder.none,
         hintText: 'What\'s happening?',
         hintStyle: TextStyle(fontSize: 18)
       ),
     );
   }
   Widget _imageFeed(){
     return _image == null ? Container() :
     Stack(children: <Widget>[
       Container(
          alignment: Alignment.topRight,
          child:Container(
          height: 300,
          width: fullWidth(context) *.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            image:DecorationImage(image: FileImage(_image),fit:BoxFit.cover)
          ),
          
        )
      ),
      Align(
        alignment: Alignment.topRight,
        child: Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black26
          ),
          child: IconButton( 
            padding: EdgeInsets.all(0), iconSize: 20,
            onPressed: (){
              setState(() {
                _image = null;
              });
            },
            icon: Icon(Icons.close,color: Theme.of(context).colorScheme.onPrimary),
          ),
        )
      )

     ],)
      ;
   }
   void _selectImageButton()async{
      openImagePicker(context,(value){
        setState(() {
          _image= value;
        });
      });
   }
   Widget _floatingActionButton(){
     return FloatingActionButton(
       onPressed: _selectImageButton,
       child:Icon(Icons.image)
     );
   }
   void _submitButton()async{
     if(_textEditingController.text == null || _textEditingController.text.isEmpty){
       return;
     }
     var state = Provider.of<FeedState>(context,);
     var authState = Provider.of<AuthState>(context,);
     var name = authState.userModel.displayName ?? authState.userModel.email.split('@')[0];
     var pic = authState.userModel.photoUrl ?? dummyProfilePic;
     var tags = getHashTags(_textEditingController.text);
      FeedModel _model = FeedModel(
        description: _textEditingController.text,
        userId: authState.user.uid,
        name: name,
        profilePic: pic,
        username: authState.userModel.userName,
        createdAt:  DateTime.now().toString());
   
    if(_image != null){
      await state.uploadFile(_image,_model);
      print('model');
    }
    else{
       state.createFeed(_model);
    }
    Navigator.pop(context);
   }
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context,);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: CustomAppBar(
        title: customTitleText('',),
        onActionPressed: _submitButton,
        isCrossButton :true,
         submitButtonText:'Tweet',
         isSubmitDisable: _textEditingController.text == null || _textEditingController.text.isEmpty,
      ),
     floatingActionButton:_floatingActionButton() ,
      body:
      SingleChildScrollView(
        child: Container(
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  customImage(context, state.userModel?.photoUrl ?? dummyProfilePic),
                  SizedBox(width: 20,),
                  Expanded(
                    child: _descriptionEntry(),
                  )
                ],
              ),
              _imageFeed(),
            ],
          ),
        ),
      )
    );
  }
}
