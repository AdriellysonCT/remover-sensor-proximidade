import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Forma personalizada para o thumb do slider
class CustomSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  
  const CustomSliderThumbShape({this.enabledThumbRadius = 12});
  
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }
  
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final color = sliderTheme.thumbColor ?? Colors.blue;
    
    // Desenha o círculo externo (overlay)
    final overlayPaint = Paint()
      ..color = (sliderTheme.overlayColor ?? Colors.blue).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius * 2, overlayPaint);
    
    // Desenha o thumb principal
    final thumbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius, thumbPaint);
    
    // Desenha borda branca
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);
  }
}

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
            thumbShape: const CustomSliderThumbShape(enabledThumbRadius: 12),
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.3),
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withOpacity(0.2),
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
