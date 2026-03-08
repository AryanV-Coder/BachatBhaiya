import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SiTaraGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.transparent; // MUST be transparent!

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // No more clouds/birds as requested
  }
}

class CloudComponent extends PositionComponent
    with HasGameReference<SiTaraGame> {
  final double speed;
  CloudComponent({required Vector2 position, required this.speed})
    : super(position: position, size: Vector2(90, 45));

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawCircle(Offset(size.x * 0.25, size.y * 0.65), 16, paint);
    canvas.drawCircle(Offset(size.x * 0.50, size.y * 0.45), 21, paint);
    canvas.drawCircle(Offset(size.x * 0.75, size.y * 0.65), 16, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;
    if (position.x > 1500) position.x = -100;
  }
}

class BirdComponent extends PositionComponent
    with HasGameReference<SiTaraGame> {
  double _flapTimer = 0;
  bool _wingUp = true;
  final double speed = 45;

  BirdComponent({required Vector2 position})
    : super(position: position, size: Vector2(28, 18));

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    final midY = size.y * (_wingUp ? 0.3 : 0.7);
    path.moveTo(size.x * 0.5, size.y * 0.5);
    path.quadraticBezierTo(size.x * 0.25, midY, 0, size.y * 0.5);
    path.moveTo(size.x * 0.5, size.y * 0.5);
    path.quadraticBezierTo(size.x * 0.75, midY, size.x, size.y * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;
    _flapTimer += dt;
    if (_flapTimer >= 0.28) {
      _wingUp = !_wingUp;
      _flapTimer = 0;
    }
    if (position.x > 1500) {
      position.x = -50;
    }
  }
}
