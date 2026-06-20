import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Widget que mostra o status do sensor de proximidade em tempo real
class SensorStatusCard extends StatelessWidget {
  final double distance;
  final bool isNear;
  final bool isMonitoring;

  const SensorStatusCard({
    super.key,
    required this.distance,
    required this.isNear,
    required this.isMonitoring,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isNear ? Icons.warning : Icons.check_circle,
                  color: isNear ? AppTheme.warningColor : AppTheme.successColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Status do Sensor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isMonitoring)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sensor não está sendo monitorado',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distância',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${distance.toStringAsFixed(2)} cm',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isNear ? AppTheme.warningColor : AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isNear
                                ? AppTheme.warningColor.withOpacity(0.2)
                                : AppTheme.successColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isNear ? 'Próximo ⚠️' : 'Distante ✅',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isNear
                                  ? AppTheme.warningColor
                                  : AppTheme.successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
