import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HudBar extends StatelessWidget {
  final String label;
  final double? progress;
  final String? balanceText;
  final Color barColor;
  final IconData icon;
  final Color iconColor;
  final Color textColor;

  const HudBar({
    super.key,
    required this.label,
    this.progress,
    this.balanceText,
    required this.barColor,
    required this.icon,
    required this.iconColor,
    this.textColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.hudBg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.panelBrown, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle icon badge
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                if (progress != null) _buildBar(),
                if (balanceText != null) _buildBalance(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 110),
      height: 13,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress!.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: LinearGradient(
              colors: [barColor, barColor.withValues(alpha: 0.75)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalance() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        balanceText ?? '',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor == Colors.black87
              ? AppColors.balanceGold
              : textColor,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}
