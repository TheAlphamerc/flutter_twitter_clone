import 'package:flutter/material.dart';

class RippleButton extends StatelessWidget {
  final Widget child;
  final Function? onPressed;
  final BorderRadius borderRadius;
  final Color? splashColor;
  const RippleButton(
      {Key? key,
      required this.child,
      this.onPressed,
      this.borderRadius = const BorderRadius.all(Radius.circular(0)),
      this.splashColor})
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
          child: TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: borderRadius)),
                foregroundColor: MaterialStateProperty.all(splashColor),
              ),
              onPressed: () {
                if (onPressed != null) {
                  onPressed!();
                }
              },
              child: Container()),
        )
      ],
    );
  }
}
