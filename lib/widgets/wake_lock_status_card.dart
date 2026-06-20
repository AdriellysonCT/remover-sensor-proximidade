import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Widget que mostra o status do WakeLock
class WakeLockStatusCard extends StatelessWidget {
  final bool isActive;

  const WakeLockStatusCard({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.successColor.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.power : Icons.power_off,
                color: isActive ? AppTheme.successColor : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WakeLock',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActive ? 'ATIVO' : 'INATIVO',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppTheme.successColor : Colors.grey,
                    ),
                  ),
                  Text(
                    isActive
                        ? 'Tela mantida ligada'
                        : 'Tela pode apagar normalmente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isActive ? Icons.check_circle : Icons.cancel,
              color: isActive ? AppTheme.successColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
