import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';

class TabIndicator extends Decoration {
  final BoxPainter _painter;

  TabIndicator() : _painter = _TabPainter();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _TabPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset blueLineOffset1 = offset + Offset(0, cfg.size!.height);
    final Offset greyLineOffset2 = Offset(0, cfg.size!.height + 1);

    final Offset blueLinePaint2 =
        offset + Offset(cfg.size!.width, cfg.size!.height);
    final Offset greyLineOffset1 =
        offset + Offset(cfg.size!.width * 3, cfg.size!.height + 1);

    var blueLinePaint = Paint()
      ..color = TwitterColor.dodgeBlue
      ..strokeWidth = 2;
    var greyLinePaint = Paint()
      ..color = AppColor.lightGrey
      ..strokeWidth = .2;

    canvas.drawLine(greyLineOffset1, greyLineOffset2, greyLinePaint);
    canvas.drawLine(blueLineOffset1, blueLinePaint2, blueLinePaint);
  }
}
