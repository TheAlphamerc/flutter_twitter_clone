import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:io';

class HalfPainter extends CustomPainter {
  HalfPainter(Color paintColor) {
    arcPaint = Paint()..color = paintColor;
  }

  late Paint arcPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect largeRect = Rect.fromLTWH(10, 0, size.width - 20, 70);
    final Rect beforeRect = Rect.fromLTWH(0, (size.height / 2) - 9, 10, 10);
    final Rect afterRect =
        Rect.fromLTWH(size.width - 10, (size.height / 2) - 9, 10, 10);

    final path = Path();
    if (Platform.isAndroid) {
      path.arcTo(beforeRect, radians(0), radians(90), false);
      path.lineTo(20, size.height / 2);
      path.arcTo(largeRect, radians(0), -radians(180), false);
      path.moveTo(size.width - 10, size.height / 2);
      path.lineTo(size.width - 10, (size.height / 2) - 10);
      path.arcTo(afterRect, radians(180), radians(-90), false);
      path.close();
    }

    canvas.drawPath(path, arcPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
