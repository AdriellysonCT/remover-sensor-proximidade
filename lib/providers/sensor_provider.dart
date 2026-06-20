import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_data.dart';
import '../services/sensor_monitor_service.dart';
import '../utils/constants.dart';

/// Provider para gerenciar o estado do sensor de proximidade
class SensorState {
  final double distance;
  final bool isNear;
  final bool isMonitoring;
  final List<SensorData> history;
  final DateTime? lastActivation;

  const SensorState({
    required this.distance,
    required this.isNear,
    required this.isMonitoring,
    required this.history,
    this.lastActivation,
  });

  factory SensorState.initial() {
    return const SensorState(
      distance: 0.0,
      isNear: false,
      isMonitoring: false,
      history: [],
      lastActivation: null,
    );
  }

  SensorState copyWith({
    double? distance,
    bool? isNear,
    bool? isMonitoring,
    List<SensorData>? history,
    DateTime? lastActivation,
  }) {
    return SensorState(
      distance: distance ?? this.distance,
      isNear: isNear ?? this.isNear,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      history: history ?? this.history,
      lastActivation: lastActivation ?? this.lastActivation,
    );
  }
}

class SensorNotifier extends StateNotifier<SensorState> {
  final SharedPreferences _prefs;
  StreamSubscription<SensorData>? _subscription;
  double _sensitivity;

  SensorNotifier(this._prefs) : super(SensorState.initial()) {
    _sensitivity = _prefs.getDouble(AppConstants.keySensorSensitivity) 
        ?? AppConstants.defaultSensitivity;
    SensorMonitorService.setSensitivity(_sensitivity);
  }

  /// Inicia o monitoramento do sensor
  Future<bool> startMonitoring() async {
    try {
      if (state.isMonitoring) {
        return true;
      }

      final success = await SensorMonitorService.startMonitoring(
        sensitivity: _sensitivity,
      );

      if (success) {
        // Escuta as atualizações do sensor
        _subscription = SensorMonitorService.sensorStream.listen(_onSensorData);
        
        state = state.copyWith(isMonitoring: true);
        return true;
      }

      return false;
    } catch (e) {
      print('Erro ao iniciar monitoramento: $e');
      return false;
    }
  }

  /// Para o monitoramento do sensor
  Future<void> stopMonitoring() async {
    try {
      await _subscription?.cancel();
      _subscription = null;
      await SensorMonitorService.stopMonitoring();
      state = state.copyWith(isMonitoring: false);
    } catch (e) {
      print('Erro ao parar monitoramento: $e');
    }
  }

  /// Manipula os dados recebidos do sensor
  void _onSensorData(SensorData data) {
    // Adiciona ao histórico (mantém últimos 100)
    final newHistory = List<SensorData>.from(state.history)..add(data);
    if (newHistory.length > 100) {
      newHistory.removeAt(0);
    }

    // Verifica se houve uma ativação (mudou de distante para próximo)
    DateTime? lastActivation = state.lastActivation;
    if (data.isNear && !state.isNear) {
      lastActivation = DateTime.now();
    }

    state = state.copyWith(
      distance: data.distance,
      isNear: data.isNear,
      history: newHistory,
      lastActivation: lastActivation,
    );
  }

  /// Atualiza a sensibilidade do sensor
  Future<void> updateSensitivity(double sensitivity) async {
    _sensitivity = sensitivity;
    await _prefs.setDouble(AppConstants.keySensorSensitivity, sensitivity);
    SensorMonitorService.setSensitivity(sensitivity);

    // Reinicia o monitoramento com nova sensibilidade
    if (state.isMonitoring) {
      await stopMonitoring();
      await startMonitoring();
    }
  }

  /// Obtém o valor da sensibilidade atual
  double get sensitivity => _sensitivity;

  @override
  void dispose() {
    _subscription?.cancel();
    SensorMonitorService.dispose();
    super.dispose();
  }
}

final sensorProvider = StateNotifierProvider<SensorNotifier, SensorState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SensorNotifier(prefs);
});
