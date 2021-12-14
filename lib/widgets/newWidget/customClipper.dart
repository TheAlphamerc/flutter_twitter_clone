import 'package:flutter/material.dart';

class WavyHeaderImage extends StatefulWidget {
  final Widget child;

  const WavyHeaderImage({Key? key, required this.child}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _WavyHeaderState();
  }
}

class _WavyHeaderState extends State<WavyHeaderImage> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: widget
          .child, // Container(height:context.height,width: context.width,color:Colors.grey.shade100,),
      clipper: BottomWaveClipper(),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    var thirdControlPoint =
        Offset(size.width - (size.width / 5), size.height - size.height / 3.25);
    var thirdEndPoint = Offset(size.width - 50, size.height / 2);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy,
        thirdEndPoint.dx, thirdEndPoint.dy);

    // path.lineTo(size.width, 0);

    var fourthControlPoint = Offset(size.width, size.height / 4);
    var fourthEndPoint = Offset(size.width - 40, 0);
    path.quadraticBezierTo(fourthControlPoint.dx, fourthControlPoint.dy,
        fourthEndPoint.dx, fourthEndPoint.dy);

    path.lineTo(size.width, 0);
    // path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
