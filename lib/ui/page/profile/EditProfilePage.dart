import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/customRoute.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/ui/page/profile/widgets/circular_image.dart';
import 'package:flutter_twitter_clone/widgets/cache_image.dart';
import 'package:flutter_twitter_clone/widgets/customFlatButton.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key key}) : super(key: key);
  static MaterialPageRoute<T> getRoute<T>() {
    return CustomRoute<T>(builder: (BuildContext context) => EditProfilePage());
  }

  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File _image;
  File _banner;
  TextEditingController _name;
  TextEditingController _bio;
  TextEditingController _location;
  TextEditingController _dob;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String dob;
  @override
  void initState() {
    _name = TextEditingController();
    _bio = TextEditingController();
    _location = TextEditingController();
    _dob = TextEditingController();
    var state = Provider.of<AuthState>(context, listen: false);
    _name.text = state?.userModel?.displayName;
    _bio.text = state?.userModel?.bio;
    _location.text = state?.userModel?.location;
    _dob.text = Utility.getdob(state?.userModel?.dob);
    super.initState();
  }

  void dispose() {
    _name.dispose();
    _bio.dispose();
    _location.dispose();
    _dob.dispose();
    super.dispose();
  }

  Widget _body() {
    var authstate = Provider.of<AuthState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 180,
          child: Stack(
            children: <Widget>[
              _bannerImage(authstate),
              Align(
                alignment: Alignment.bottomLeft,
                child: _userImage(authstate),
              ),
            ],
          ),
        ),
        _entry('Name', controller: _name),
        _entry('Bio', controller: _bio, maxLine: null),
        _entry('Location', controller: _location),
        InkWell(
          onTap: showCalender,
          child: _entry('Date of birth', isenable: false, controller: _dob),
        )
      ],
    );
  }

  Widget _userImage(AuthState authstate) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 5),
        shape: BoxShape.circle,
        image: DecorationImage(
            image: customAdvanceNetworkImage(authstate.userModel.profilePic),
            fit: BoxFit.cover),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundImage: _image != null
            ? FileImage(_image)
            : customAdvanceNetworkImage(authstate.userModel.profilePic),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black38,
          ),
          child: Center(
            child: IconButton(
              onPressed: uploadImage,
              icon: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bannerImage(AuthState authstate) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        image: authstate.userModel.bannerImage == null
            ? null
            : DecorationImage(
                image:
                    customAdvanceNetworkImage(authstate.userModel.bannerImage),
                fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
        ),
        child: Stack(
          children: [
            _banner != null
                ? Image.file(_banner,
                    fit: BoxFit.fill, width: MediaQuery.of(context).size.width)
                : CacheImage(
                    path: authstate.userModel.bannerImage ??
                        'https://pbs.twimg.com/profile_banners/457684585/1510495215/1500x500',
                    fit: BoxFit.fill),
            Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black38),
                child: IconButton(
                  onPressed: uploadBanner,
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entry(String title,
      {TextEditingController controller,
      int maxLine = 1,
      bool isenable = true}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          customText(title, style: TextStyle(color: Colors.black54)),
          TextField(
            enabled: isenable,
            controller: controller,
            maxLines: maxLine,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            ),
          )
        ],
      ),
    );
  }

  void showCalender() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2019, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(1950, DateTime.now().month, DateTime.now().day + 3),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    setState(() {
      if (picked != null) {
        dob = picked.toString();
        _dob.text = Utility.getdob(dob);
      }
    });
  }

  void _submitButton() {
    if (_name.text.length > 27) {
      Utility.customSnackBar(
          _scaffoldKey, 'Name length cannot exceed 27 character');
      return;
    }
    var state = Provider.of<AuthState>(context, listen: false);
    var model = state.userModel.copyWith(
      key: state.userModel.userId,
      displayName: state.userModel.displayName,
      bio: state.userModel.bio,
      contact: state.userModel.contact,
      dob: state.userModel.dob,
      email: state.userModel.email,
      location: state.userModel.location,
      profilePic: state.userModel.profilePic,
      userId: state.userModel.userId,
      bannerImage: state.userModel.bannerImage,
    );
    if (_name.text != null && _name.text.isNotEmpty) {
      model.displayName = _name.text;
    }
    if (_bio.text != null && _bio.text.isNotEmpty) {
      model.bio = _bio.text;
    }
    if (_location.text != null && _location.text.isNotEmpty) {
      model.location = _location.text;
    }
    if (dob != null) {
      model.dob = dob;
    }

    state.updateUserProfile(model, image: _image, bannerImage: _banner);
    Navigator.of(context).pop();
  }

  void uploadImage() {
    openImagePicker(context, (file) {
      setState(() {
        _image = file;
      });
    });
  }

  void uploadBanner() {
    openImagePicker(context, (file) {
      setState(() {
        _banner = file;
      });
    });
  }

  openImagePicker(BuildContext context, Function(File) onImageSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Text(
                'Pick an image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomFlatButton(
                      label: "Use Camera",
                      borderRadius: 5,
                      onPressed: () {
                        getImage(context, ImageSource.camera, onImageSelected);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomFlatButton(
                      label: "Use Gallery",
                      borderRadius: 5,
                      onPressed: () {
                        getImage(context, ImageSource.gallery, onImageSelected);
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  getImage(BuildContext context, ImageSource source,
      Function(File) onImageSelected) {
    ImagePicker()
        .pickImage(source: source, imageQuality: 50)
        .then((XFile file) {
      onImageSelected(File(file.path));
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue),
        title: customTitleText('Profile Edit'),
        actions: <Widget>[
          InkWell(
            onTap: _submitButton,
            child: Center(
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: _body(),
      ),
    );
  }
}
