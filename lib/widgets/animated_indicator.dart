import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Widget animado que indica o status do sensor
class AnimatedSensorIndicator extends StatelessWidget {
  final bool isNear;
  final double distance;

  const AnimatedSensorIndicator({
    super.key,
    required this.isNear,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isNear
              ? [
                  AppTheme.warningColor.withOpacity(0.4),
                  AppTheme.warningColor.withOpacity(0.1),
                ]
              : [
                  AppTheme.successColor.withOpacity(0.4),
                  AppTheme.successColor.withOpacity(0.1),
                ],
          stops: const [0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: isNear
                ? AppTheme.warningColor.withOpacity(0.5)
                : AppTheme.successColor.withOpacity(0.5),
            blurRadius: isNear ? 20 : 15,
            spreadRadius: isNear ? 5 : 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(
              begin: isNear ? 0 : 1,
              end: isNear ? 1 : 0,
            ),
            builder: (context, value, child) {
              return Icon(
                isNear ? Icons.hand : Icons.pan_tool_outlined,
                size: 64 + (value * 8),
                color: isNear ? AppTheme.warningColor : AppTheme.successColor,
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              isNear ? 'Próximo ⚠️' : 'Distante ✅',
              key: ValueKey<bool>(isNear),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isNear ? AppTheme.warningColor : AppTheme.successColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${distance.toStringAsFixed(2)} cm',
            style: TextStyle(
              fontSize: 16,
              color: isNear ? AppTheme.warningColor : AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }
}
