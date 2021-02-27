import 'package:flutter/material.dart';

class CustomFlatButton extends StatelessWidget {
  const CustomFlatButton({
    Key key,
    this.onPressed,
    this.label,
    this.isLoading,
    this.color,
    this.labelStyle,
    this.isWraped = false,
    this.isColored = true,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);
  final Function onPressed;
  final String label;
  final TextStyle labelStyle;
  final ValueNotifier<bool> isLoading;
  final bool isWraped;
  final bool isColored;
  final Color color;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWraped ? null : double.infinity,
      child: ValueListenableBuilder<bool>(
        valueListenable: isLoading ?? ValueNotifier(false),
        builder: (context, loading, child) {
          return FlatButton(
            disabledColor: Theme.of(context).disabledColor,
            padding: padding,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            color: !isColored ? null : color ?? Theme.of(context).primaryColor,
            splashColor: Theme.of(context).colorScheme.background,
            textColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: loading ? null : onPressed,
            child: loading
                ? SizedBox(
                    height: 15,
                    width: 15,
                    child: FittedBox(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                            color ?? Theme.of(context).primaryColor),
                      ),
                    ),
                  )
                : child,
          );
        },
        child: Text(label,
            style: labelStyle ??
                Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Colors.white)),
      ),
    );
  }
}
