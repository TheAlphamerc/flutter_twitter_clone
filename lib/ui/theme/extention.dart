part of 'theme.dart';

extension SizeHelper on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  double getDimention(context, double unit) {
    if (width <= 360.0) {
      return unit / 1.3;
    } else {
      return unit;
    }
  }
}

extension OnPressed on Widget {
  Widget ripple(Function? onPressed,
          {BorderRadiusGeometry borderRadius =
              const BorderRadius.all(Radius.circular(5))}) =>
      Stack(
        children: <Widget>[
          this,
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: TextButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: borderRadius),
                    )),
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

extension StringHelper on String {
  String takeOnly(int value) {
    if (length > value) {
      return substring(0, value) + " ...";
    }
    return this;
  }

  String get removeSpaces {
    if (length > 0) {
      return replaceAll(RegExp(r"\n+"), "\n");
    }
    return this;
  }
}
