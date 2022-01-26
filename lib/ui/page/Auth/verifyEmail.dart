import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  final VoidCallback? loginCallback;

  const VerifyEmailPage({Key? key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _body(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    return Container(
      height: context.height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: state.user!.emailVerified
            ? <Widget>[
                NotifyText(
                  title: 'Your email address is verified',
                  subTitle:
                      'You have got your blue tick on your name. Cheers !!',
                ),
              ]
            : <Widget>[
                NotifyText(
                  title: 'Verify your email address',
                  subTitle:
                      'Send email verification email link to ${state.user!.email} to verify address',
                ),
                const SizedBox(
                  height: 30,
                ),
                _submitButton(context),
              ],
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Wrap(
        children: <Widget>[
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color: Colors.blueAccent,
            onPressed: _submit,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: const TitleText(
              'Send Link',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.sendEmailVerification(_scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TwitterColor.mystic,
      appBar: AppBar(
        title: customText(
          'Email Verification',
          context: context,
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
}
