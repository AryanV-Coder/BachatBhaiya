import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class BackgroundWorld extends StatelessWidget {
  const BackgroundWorld({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: SizedBox(
        width: AppSizes.worldWidth,
        height: AppSizes.worldHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            // Subtle vignette for depth
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _fallbackBackground() {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topCenter,
  //         end: Alignment.bottomCenter,
  //         colors: [
  //           Color(0xFF87CEEB),
  //           Color(0xFFB8E49A),
  //           Color(0xFFD4A574),
  //         ],
  //         stops: [0.0, 0.5, 1.0],
  //       ),
  //     ),
  //   );
  // }
}
