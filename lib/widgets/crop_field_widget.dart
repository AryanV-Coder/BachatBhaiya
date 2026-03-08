import 'package:flutter/material.dart';

class CropFieldWidget extends StatefulWidget {
  final String cropName;
  final Color cropColor;
  final bool isLocked;

  const CropFieldWidget({
    super.key,
    required this.cropName,
    required this.cropColor,
    this.isLocked = false,
  });

  @override
  State<CropFieldWidget> createState() => _CropFieldWidgetState();
}

class _CropFieldWidgetState extends State<CropFieldWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _swayController;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();
    // Crops gently sway in the wind
    _swayController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _swayAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Field grid (rows of crops)
        Container(
          width: 140,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF8B6914).withValues(alpha: 0.4), // Dirt
            border: Border.all(color: const Color(0xFF654321), width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: widget.isLocked
              ? const Center(
                  child: Icon(Icons.lock, color: Colors.white70, size: 30))
              : GridView.count(
                  crossAxisCount: 5,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(4),
                  children: List.generate(20, (i) => AnimatedBuilder(
                    animation: _swayAnimation,
                    builder: (context, child) => Transform.rotate(
                      angle: _swayAnimation.value,
                      child: child,
                    ),
                    child: Icon(
                      Icons.grass,
                      color: widget.cropColor,
                      size: 16,
                    ),
                  )),
                ),
        ),
        // Lock icon if field is locked
        if (widget.isLocked)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: Colors.white, size: 14),
            ),
          ),
      ],
    );
  }
}