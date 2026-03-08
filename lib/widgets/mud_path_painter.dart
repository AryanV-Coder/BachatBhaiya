import 'package:flutter/material.dart';
import 'dart:math' as math;

class MudPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Defining common mud colors
    final baseMudColor = const Color(0xFF8B4513);
    final darkMudColor = const Color(0xFF5D2E0A);
    final lightMudColor = const Color(0xFFA0522D);

    // Positions of widgets (Center points)
    final hut = const Offset(1110, 580);
    final well = const Offset(1060, 210);
    final stockMarket = const Offset(300, 450);
    final generalMarket = const Offset(230, 850); // Updated market position
    final fields = const Offset(1675, 780);

    // Connections to draw
    final connections = [
      [hut, well],
      [hut, stockMarket],
      [stockMarket, generalMarket],
      [hut, fields],
    ];

    for (var conn in connections) {
      _drawRealisticPath(
        canvas,
        conn[0],
        conn[1],
        baseMudColor,
        darkMudColor,
        lightMudColor,
      );
    }
  }

  void _drawRealisticPath(
    Canvas canvas,
    Offset start,
    Offset end,
    Color base,
    Color dark,
    Color light,
  ) {
    final random = math.Random(start.dx.toInt() ^ end.dy.toInt());

    // 1. Draw the broad "pressed" area (very faint, wide)
    final outerPaint = Paint()
      ..color = base.withValues(alpha: 0.15)
      ..strokeWidth = 50.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    _drawWobblyPath(canvas, start, end, outerPaint, random, 10.0);

    // 2. Draw the main mud path
    final mainPaint = Paint()
      ..color = base.withValues(alpha: 0.35)
      ..strokeWidth = 32.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    _drawWobblyPath(canvas, start, end, mainPaint, random, 8.0);

    // 3. Draw the "center track" (darker, thinner)
    final centerPaint = Paint()
      ..color = dark.withValues(alpha: 0.25)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _drawWobblyPath(canvas, start, end, centerPaint, random, 5.0);

    // 4. Add some "dirt patches" or footprints along the path
    final patchPaint = Paint()..style = PaintingStyle.fill;
    double dist = (end - start).distance;
    int steps = (dist / 25).floor();

    for (int i = 0; i < steps; i++) {
      double t = i / steps;
      Offset pos = Offset.lerp(start, end, t)!;
      pos += Offset(
        random.nextDouble() * 25 - 12,
        random.nextDouble() * 25 - 12,
      );

      patchPaint.color = (random.nextBool() ? dark : light).withValues(alpha: 0.2);
      double radius = random.nextDouble() * 10 + 5;
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: radius * 1.5, height: radius),
        patchPaint,
      );
    }
  }

  void _drawWobblyPath(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    math.Random random,
    double wobbleAmount,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final control = Offset(
      mid.dx + (random.nextDouble() * 120 - 60),
      mid.dy + (random.nextDouble() * 120 - 60),
    );

    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
