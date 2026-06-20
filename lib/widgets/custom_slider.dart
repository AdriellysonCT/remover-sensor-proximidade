import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Widget de slider customizado para sensibilidade
class CustomSensitivitySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  const CustomSensitivitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1.0,
    this.max = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sensibilidade do Sensor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${value.toStringAsFixed(1)} cm',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Distância máxima para detectar proximidade',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.3),
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withOpacity(0.2),
            tickMarkShape: const RoundSliderTickMarkShape(),
            activeTickMarkColor: Colors.white,
            inactiveTickMarkColor: Colors.grey.withOpacity(0.5),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: 18, // Permite incrementos de 0.5
            label: '${value.toStringAsFixed(1)} cm',
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mais sensível',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            Text(
              'Menos sensível',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
