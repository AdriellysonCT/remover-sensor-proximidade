import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../utils/theme.dart';

/// Widget de toggle grande para ativar/desativar a proteção
class ProtectionToggle extends ConsumerStatefulWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const ProtectionToggle({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  ConsumerState<ProtectionToggle> createState() => _ProtectionToggleState();
}

class _ProtectionToggleState extends ConsumerState<ProtectionToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    _controller.forward().then((_) => _controller.reverse());
    
    // Feedback tátil
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50);
    }

    // Chama o callback após pequena delay para animação
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onChanged(!widget.isEnabled);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.isEnabled;
    
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isEnabled
                      ? [
                          AppTheme.successColor.withValues(alpha: 0.3),
                          AppTheme.successColor.withValues(alpha: 0.1),
                        ]
                      : [
                          AppTheme.errorColor.withValues(alpha: 0.3),
                          AppTheme.errorColor.withValues(alpha: 0.1),
                        ],
                  stops: const [0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isEnabled
                        ? AppTheme.successColor.withValues(alpha: 0.4)
                        : AppTheme.errorColor.withValues(alpha: 0.4),
                    blurRadius: isEnabled ? 30 : 20,
                    spreadRadius: isEnabled ? 10 : 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEnabled ? Icons.shield : Icons.shield_outlined,
                    size: 80,
                    color: isEnabled
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEnabled ? 'PROTEÇÃO\nATIVA' : 'PROTEÇÃO\nINATIVA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isEnabled
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEnabled ? 'Toque para desativar' : 'Toque para ativar',
                    style: TextStyle(
                      fontSize: 14,
                      color: isEnabled
                          ? AppTheme.successColor.withValues(alpha: 0.8)
                          : AppTheme.errorColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
