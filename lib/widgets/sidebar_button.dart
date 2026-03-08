import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// The Profile, Chat, Quiz buttons on the left side
class SidebarButton extends StatefulWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final VoidCallback onTap; // What happens when tapped
  final Color color;

  const SidebarButton({
    super.key,
    this.icon,
    this.imagePath,
    required this.label,
    required this.onTap,
    this.color = AppColors.panelBrown,
  });

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton>
    with SingleTickerProviderStateMixin {
  // AnimationController lets us control the "press" animation
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    // When pressed, scale down to 90% size
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(), // Shrink on press
      onTapUp: (_) {
        _controller.reverse(); // Expand on release
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(), // Expand if cancelled
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 65,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.imagePath != null)
                Image.asset(
                  widget.imagePath!,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                )
              else if (widget.icon != null)
                Icon(widget.icon, color: widget.color, size: 28),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
