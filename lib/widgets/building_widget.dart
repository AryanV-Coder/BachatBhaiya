import 'package:flutter/material.dart';

class BuildingWidget extends StatefulWidget {
  final String name;
  final IconData icon;
  final Color roofColor;
  final Color wallColor;
  final double size;
  final VoidCallback onTap;

  const BuildingWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.roofColor,
    required this.wallColor,
    this.size = 100,
    required this.onTap,
  });

  @override
  State<BuildingWidget> createState() => _BuildingWidgetState();
}

class _BuildingWidgetState extends State<BuildingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounce;
  late Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    // Gentle floating animation — each building slightly offset in phase
    _bounce = AnimationController(
      duration: Duration(milliseconds: 1800 + widget.name.length * 100),
      vsync: this,
    )..repeat(reverse: true);
    _offset = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _bounce, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main building body
            Container(
              width: widget.size,
              height: widget.size * 0.85,
              decoration: BoxDecoration(
                color: widget.wallColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Triangular roof
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: _RoofClipper(),
                      child: Container(
                        height: widget.size * 0.32,
                        color: widget.roofColor,
                      ),
                    ),
                  ),
                  // Building icon
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: widget.size * 0.25),
                      child: Icon(
                        widget.icon,
                        size: widget.size * 0.3,
                        color: widget.roofColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Name label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoofClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> old) => false;
}