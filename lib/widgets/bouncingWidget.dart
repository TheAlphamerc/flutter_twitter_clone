import 'package:flutter/material.dart';

class BoundingWidget extends StatefulWidget {
  final Widget child;

  const BoundingWidget({@required this.child});
  @override
  _BoundingWidgetState createState() => _BoundingWidgetState();
}

class _BoundingWidgetState extends State<BoundingWidget>
    with SingleTickerProviderStateMixin {
  double _scale;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.5,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTap: (){
        _controller.forward();
         Future.delayed(Duration(milliseconds: 200), () {
          _controller.reverse();
        });
      },
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}