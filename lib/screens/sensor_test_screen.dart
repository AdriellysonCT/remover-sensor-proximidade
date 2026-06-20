import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sensor_provider.dart';
import '../utils/theme.dart';

/// Tela de teste do sensor de proximidade
class SensorTestScreen extends ConsumerStatefulWidget {
  const SensorTestScreen({super.key});

  @override
  ConsumerState<SensorTestScreen> createState() => _SensorTestScreenState();
}

class _SensorTestScreenState extends ConsumerState<SensorTestScreen> {
  bool _isMonitoring = false;
  final List<FlSpot> _distanceSpots = [];
  Timer? _chartUpdateTimer;
  int _spotCounter = 0;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _stopMonitoring();
    _chartUpdateTimer?.cancel();
    super.dispose();
  }

  /// Inicia o monitoramento do sensor
  Future<void> _startMonitoring() async {
    setState(() => _isMonitoring = true);
    
    final sensorNotifier = ref.read(sensorProvider.notifier);
    await sensorNotifier.startMonitoring();

    // Atualiza o gráfico periodicamente
    _chartUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _updateChart();
    });
  }

  /// Para o monitoramento do sensor
  Future<void> _stopMonitoring() async {
    final sensorNotifier = ref.read(sensorProvider.notifier);
    await sensorNotifier.stopMonitoring();
    
    setState(() => _isMonitoring = false);
    _chartUpdateTimer?.cancel();
  }

  /// Atualiza os dados do gráfico
  void _updateChart() {
    final sensorState = ref.read(sensorProvider);
    
    setState(() {
      if (_distanceSpots.length > 50) {
        _distanceSpots.removeAt(0);
      }
      
      _distanceSpots.add(FlSpot(
        _spotCounter.toDouble(),
        sensorState.distance,
      ));
      
      _spotCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensorState = ref.watch(sensorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Testar Sensor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card informativo
            Card(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aproxime e afaste objetos do topo do celular para testar o sensor. Os valores devem mudar conforme a distância.',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Indicador animado grande
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sensorState.isNear
                      ? AppTheme.warningColor.withValues(alpha: 0.2)
                      : AppTheme.successColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: sensorState.isNear
                        ? AppTheme.warningColor
                        : AppTheme.successColor,
                    width: 3,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sensorState.isNear ? Icons.touch_app : Icons.pan_tool_outlined,
                      size: 80,
                      color: sensorState.isNear
                          ? AppTheme.warningColor
                          : AppTheme.successColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      sensorState.isNear ? 'PRÓXIMO' : 'DISTANTE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: sensorState.isNear
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Valores brutos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valores do Sensor',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildValueRow('Distância:', '${sensorState.distance.toStringAsFixed(2)} cm'),
                    const Divider(height: 24),
                    _buildValueRow('Status:', sensorState.isNear ? 'Próximo ⚠️' : 'Distante ✅'),
                    const Divider(height: 24),
                    _buildValueRow(
                      'Monitorando:',
                      _isMonitoring ? 'Sim ✅' : 'Não ❌',
                      valueColor: _isMonitoring ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Gráfico
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Histórico (últimas leituras)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _distanceSpots.isEmpty
                          ? Center(
                              child: Text(
                                'Aguardando dados...',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            )
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 2,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: false,
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: _distanceSpots.isNotEmpty
                                    ? _distanceSpots.last.x
                                    : 50,
                                minY: 0,
                                maxY: 10,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _distanceSpots,
                                    isCurved: true,
                                    color: AppTheme.primaryColor,
                                    barWidth: 3,
                                    dotData: FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
                    icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
                    label: Text(_isMonitoring ? 'Parar' : 'Iniciar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: _isMonitoring
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _distanceSpots.clear();
                        _spotCounter = 0;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Limpar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
