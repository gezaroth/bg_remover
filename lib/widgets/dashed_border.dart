import 'dart:ui';

import 'package:flutter/material.dart';

class DashedBorder extends StatefulWidget {
  final Color? color;
  final double strockeWidth;
  final double dotsWidth;
  final double gap;
  final double radius;
  final Widget child;
  final EdgeInsets? padding;

  const DashedBorder({
    Key? key,
    this.color = Colors.black,
    this.strockeWidth = 1.0,
    this.dotsWidth = 5.0,
    this.gap = 3.0,
    this.radius = 0,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  State<DashedBorder> createState() => _DashedBorderState();
}

class _DashedBorderState extends State<DashedBorder> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedCustomPaint(
        color: widget.color!,
        dottedLenght: widget.dotsWidth,
        space: widget.gap,
        strokewidth: widget.strockeWidth,
        radius: widget.radius,
      ),
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(2),
        child: widget.child,
      ),
    );
  }
}

class _DottedCustomPaint extends CustomPainter {
  Color? color;
  double? dottedLenght;
  double? space;
  double? strokewidth;
  double? radius;

  _DottedCustomPaint({
    this.color,
    this.dottedLenght,
    this.space,
    this.strokewidth,
    this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..color = color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokewidth!;

    Path path = Path();
    path.addRRect(RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(radius!),
    ));

    Path draw = buildDashPath(path, dottedLenght!, space!);
    canvas.drawPath(draw, paint);
  }

  Path buildDashPath(Path path, double dottedLenght, double space) {
    final Path r = Path();
    for (PathMetric metric in path.computeMetrics()) {
      double start = 0.0;
      while (start < metric.length) {
        double end = start + dottedLenght;
        r.addPath(metric.extractPath(start, end), Offset.zero);
        start = end + space;
      }
    }
    return r;
  }

  @override
  bool shouldRepaint(_DottedCustomPaint oldDelegate) {
    return true;
  }
}
