import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';

class RippleButton extends StatelessWidget {
  final Widget child;
  final Function onPressed;
  final BorderRadius borderRadius;
  final Color splashColor;
  RippleButton({Key key, this.child, this.onPressed, this.borderRadius = const BorderRadius.all(Radius.circular(0)), this.splashColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: FlatButton(
            splashColor: splashColor,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius
            ),
              onPressed: () {
                if (onPressed != null) {
                  onPressed();
                }
              },
              child: Container()),
        )
      ],
    );
  }
}
