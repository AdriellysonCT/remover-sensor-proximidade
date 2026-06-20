import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_data.dart';
import '../utils/constants.dart';

/// Provider para gerenciar estatísticas de uso
class StatsState {
  final int activationCount;
  final DateTime lastActivationDate;
  final List<SensorData> recentActivations;

  const StatsState({
    required this.activationCount,
    required this.lastActivationDate,
    required this.recentActivations,
  });

  factory StatsState.initial() {
    return StatsState(
      activationCount: 0,
      lastActivationDate: DateTime.now(),
      recentActivations: [],
    );
  }

  StatsState copyWith({
    int? activationCount,
    DateTime? lastActivationDate,
    List<SensorData>? recentActivations,
  }) {
    return StatsState(
      activationCount: activationCount ?? this.activationCount,
      lastActivationDate: lastActivationDate ?? this.lastActivationDate,
      recentActivations: recentActivations ?? this.recentActivations,
    );
  }
}

class StatsNotifier extends StateNotifier<StatsState> {
  late SharedPreferences _prefs;
  bool? _lastNearState;

  StatsNotifier() : super(StatsState.initial());

  /// Inicializa o notifier com SharedPreferences
  Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
    await _loadStats();
  }

  /// Carrega estatísticas salvas
  Future<void> _loadStats() async {
    try {
      final count = _prefs.getInt(AppConstants.keyActivationCount) ?? 0;
      final lastDateMillis = _prefs.getInt(AppConstants.keyLastActivationDate) ?? DateTime.now().millisecondsSinceEpoch;
      final lastDate = DateTime.fromMillisecondsSinceEpoch(lastDateMillis);

      // Verifica se é um novo dia e reseta o contador se necessário
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);

      int finalCount = count;
      if (todayDate.isAfter(lastDateOnly)) {
        // Novo dia, reseta o contador
        finalCount = 0;
      }

      state = StatsState(
        activationCount: finalCount,
        lastActivationDate: lastDate,
        recentActivations: [],
      );
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
    }
  }

  /// Registra uma ativação do sensor
  Future<void> registerActivation(SensorData data) async {
    // Evita contar múltiplas ativações consecutivas sem um "distante" no meio
    if (_lastNearState == true && data.isNear) {
      return; // Já está perto, não conta novamente
    }

    if (data.isNear) {
      _lastNearState = true;
      
      final newCount = state.activationCount + 1;
      final now = DateTime.now();

      // Adiciona às ativações recentes
      final newActivations = List<SensorData>.from(state.recentActivations)..add(data);
      if (newActivations.length > 100) {
        newActivations.removeAt(0);
      }

      state = state.copyWith(
        activationCount: newCount,
        lastActivationDate: now,
        recentActivations: newActivations,
      );

      // Salva no SharedPreferences
      await _prefs.setInt(AppConstants.keyActivationCount, newCount);
      await _prefs.setInt(AppConstants.keyLastActivationDate, now.millisecondsSinceEpoch);
    } else {
      _lastNearState = false;
    }
  }

  /// Reseta as estatísticas
  Future<void> resetStats() async {
    await _prefs.setInt(AppConstants.keyActivationCount, 0);
    await _prefs.setInt(AppConstants.keyLastActivationDate, DateTime.now().millisecondsSinceEpoch);
    
    state = StatsState.initial();
  }

  /// Incrementa o contador manualmente (para testes)
  Future<void> incrementCount() async {
    final newCount = state.activationCount + 1;
    await _prefs.setInt(AppConstants.keyActivationCount, newCount);
    state = state.copyWith(activationCount: newCount);
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier();
});
