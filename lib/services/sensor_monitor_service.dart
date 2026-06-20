import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_data.dart';

/// Serviço para monitorar o sensor de proximidade
class SensorMonitorService {
  static StreamSubscription<ProximityEvent>? _subscription;
  static bool _isMonitoring = false;
  static double _currentDistance = 0.0;
  static bool _isNear = false;
  
  // Threshold para determinar se está perto (em cm)
  static double _sensitivityThreshold = 5.0;

  /// Verifica se o serviço está monitorando
  static bool get isMonitoring => _isMonitoring;

  /// Retorna a distância atual do sensor
  static double get currentDistance => _currentDistance;

  /// Retorna se o sensor detecta proximidade
  static bool get isNear => _isNear;

  /// Stream dos dados do sensor
  static final _sensorStreamController = StreamController<SensorData>.broadcast();
  static Stream<SensorData> get sensorStream => _sensorStreamController.stream;

  /// Define a sensibilidade do sensor (threshold em cm)
  static void setSensitivity(double threshold) {
    _sensitivityThreshold = threshold;
  }

  /// Inicia o monitoramento do sensor de proximidade
  static Future<bool> startMonitoring({double sensitivity = 5.0}) async {
    try {
      if (_isMonitoring) {
        print('Já está monitorando o sensor');
        return true;
      }

      _sensitivityThreshold = sensitivity;
      
      // Escuta os eventos do sensor de proximidade
      _subscription = proximityEventStream().listen(
        (ProximityEvent event) {
          _handleProximityEvent(event);
        },
        onError: (error) {
          print('Erro ao ouvir sensor de proximidade: $error');
          _isMonitoring = false;
        },
        cancelOnError: false,
      );

      _isMonitoring = true;
      print('Monitoramento do sensor iniciado');
      return true;
    } catch (e) {
      print('Erro ao iniciar monitoramento do sensor: $e');
      _isMonitoring = false;
      return false;
    }
  }

  /// Manipula os eventos do sensor de proximidade
  static void _handleProximityEvent(ProximityEvent event) {
    try {
      _currentDistance = event.distance;
      
      // Determina se está perto baseado no threshold
      // Alguns sensores retornam 0.0 quando perto, outros retornam valores específicos
      _isNear = _currentDistance < _sensitivityThreshold && _currentDistance >= 0;
      
      // Cria o objeto SensorData
      final sensorData = SensorData(
        distance: _currentDistance,
        timestamp: DateTime.now(),
        isNear: _isNear,
      );

      // Emite o evento na stream
      _sensorStreamController.add(sensorData);

      print('Sensor: ${_currentDistance.toStringAsFixed(2)} cm - ${_isNear ? "Próximo" : "Distante"}');
    } catch (e) {
      print('Erro ao processar evento do sensor: $e');
    }
  }

  /// Para o monitoramento do sensor
  static Future<void> stopMonitoring() async {
    try {
      if (_subscription != null) {
        await _subscription!.cancel();
        _subscription = null;
      }
      _isMonitoring = false;
      _currentDistance = 0.0;
      _isNear = false;
      print('Monitoramento do sensor parado');
    } catch (e) {
      print('Erro ao parar monitoramento do sensor: $e');
    }
  }

  /// Reinicia o monitoramento com nova sensibilidade
  static Future<void> restartMonitoring({required double sensitivity}) async {
    await stopMonitoring();
    await startMonitoring(sensitivity: sensitivity);
  }

  /// Limpa recursos
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _sensorStreamController.close();
    _isMonitoring = false;
  }
}
