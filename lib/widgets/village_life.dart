import 'package:flutter/material.dart';
import 'dart:math' as math;

enum CharacterCategory { man, woman, kid, cow }

class VillageLife extends StatefulWidget {
  final double worldWidth;
  final double worldHeight;
  final List<Rect> obstacles; // Areas characters must avoid

  const VillageLife({
    super.key,
    required this.worldWidth,
    required this.worldHeight,
    this.obstacles = const [],
  });

  @override
  State<VillageLife> createState() => _VillageLifeState();
}

class _VillageLifeState extends State<VillageLife>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<VillageCharacter> _characters = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Spawn settings
    final spawnCounts = {
      CharacterCategory.man: 4,
      CharacterCategory.woman: 3,
      CharacterCategory.kid: 6,
      CharacterCategory.cow: 4,
    };

    spawnCounts.forEach((category, count) {
      for (int i = 0; i < count; i++) {
        String assetPrefix = '';
        int assetIndex = 1;

        if (category == CharacterCategory.man) {
          assetPrefix = 'm';
          assetIndex = _random.nextInt(4) + 1;
        } else if (category == CharacterCategory.woman) {
          assetPrefix = 'f';
          assetIndex = _random.nextInt(3) + 1;
        } else if (category == CharacterCategory.kid) {
          assetPrefix = _random.nextBool() ? 'g' : 'b';
          assetIndex = _random.nextInt(3) + 1;
        } else {
          assetPrefix = 'c';
          assetIndex = 0; // doesn't matter for cow
        }

        String assetName = assetIndex == 0
            ? 'c.png'
            : '$assetPrefix$assetIndex.png';
        _characters.add(_createValidCharacter(category, assetName));
      }
    });
  }

  VillageCharacter _createValidCharacter(
    CharacterCategory category,
    String assetName,
  ) {
    double size = category == CharacterCategory.cow
        ? 85.0 // Reduced cow size
        : (category == CharacterCategory.kid ? 55.0 : 80.0);

    Offset pos = Offset.zero;
    bool valid = false;
    int attempts = 0;

    // Attempt to find a non-overlapping spawn point
    while (!valid && attempts < 50) {
      pos = Offset(
        _random.nextDouble() * widget.worldWidth,
        (widget.worldHeight * 0.18) +
            (_random.nextDouble() *
                widget.worldHeight *
                0.75), // Walkable grass area
      );

      Rect charRect = Rect.fromCenter(center: pos, width: size, height: size);
      valid = true;
      for (var obstacle in widget.obstacles) {
        if (obstacle.overlaps(charRect)) {
          valid = false;
          break;
        }
      }
      attempts++;
    }

    return VillageCharacter(
      category: category,
      assetPath: 'assets/images/$assetName',
      position: pos,
      speed: 0.4 + _random.nextDouble() * 0.6,
      direction: _random.nextBool()
          ? 0
          : math.pi, // Orderly horizontal movement
      size: size,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var char in _characters) {
          char.update(widget.worldWidth, widget.worldHeight, widget.obstacles);
        }
        return Stack(
          children: _characters.map((char) {
            bool isMovingLeft = math.cos(char.direction) < 0;
            // For cows, we assume the original asset faces right.
            // Characters and cows will flip based on movement.
            return Positioned(
              left: char.position.dx - (char.size / 2),
              top: char.position.dy - (char.size / 2),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(
                  isMovingLeft ? -1.0 : 1.0,
                  1.0,
                  1.0,
                ),
                child: Image.asset(
                  char.assetPath,
                  width: char.size,
                  height: char.size,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class VillageCharacter {
  final CharacterCategory category;
  final String assetPath;
  Offset position;
  double speed;
  double direction;
  final double size;

  VillageCharacter({
    required this.category,
    required this.assetPath,
    required this.position,
    required this.speed,
    required this.direction,
    required this.size,
  });

  void update(double maxWidth, double maxHeight, List<Rect> obstacles) {
    Offset nextPos =
        position +
        Offset(math.cos(direction) * speed, math.sin(direction) * speed);

    Rect nextRect = Rect.fromCenter(
      center: nextPos,
      width: size * 0.6,
      height: size * 0.2,
    ); // Smaller collision box for feet

    bool collision = false;

    // Screen boundaries
    if (nextPos.dx < 0 ||
        nextPos.dx > maxWidth ||
        nextPos.dy < maxHeight * 0.18 ||
        nextPos.dy > maxHeight - 20) {
      collision = true;
    }

    // Obstacle boundaries
    if (!collision) {
      for (var obstacle in obstacles) {
        if (obstacle.overlaps(nextRect)) {
          collision = true;
          break;
        }
      }
    }

    if (collision) {
      // Orderly behavior: turn around
      direction = direction + math.pi;

      // Add a tiny bit of random variation to prevent getting stuck in a loop
      direction += (math.Random().nextDouble() - 0.5) * 0.1;

      // Move slightly in the new direction to get out of the collision zone
      position += Offset(
        math.cos(direction) * (speed + 1),
        math.sin(direction) * (speed + 1),
      );
    } else {
      position = nextPos;
    }

    // Very rarely change direction randomly to avoid total robot look
    if (math.Random().nextDouble() < 0.002) {
      direction = (math.Random().nextBool() ? 0 : math.pi);
    }
  }
}
