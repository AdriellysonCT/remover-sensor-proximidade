import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Provider para gerenciar as configurações do usuário
class SettingsState {
  final bool autoStartOnBoot;
  final bool showPersistentNotification;
  final bool vibrateOnProximity;
  final double sensorSensitivity;

  const SettingsState({
    required this.autoStartOnBoot,
    required this.showPersistentNotification,
    required this.vibrateOnProximity,
    required this.sensorSensitivity,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      autoStartOnBoot: false,
      showPersistentNotification: true,
      vibrateOnProximity: false,
      sensorSensitivity: AppConstants.defaultSensitivity,
    );
  }

  SettingsState copyWith({
    bool? autoStartOnBoot,
    bool? showPersistentNotification,
    bool? vibrateOnProximity,
    double? sensorSensitivity,
  }) {
    return SettingsState(
      autoStartOnBoot: autoStartOnBoot ?? this.autoStartOnBoot,
      showPersistentNotification: showPersistentNotification ?? this.showPersistentNotification,
      vibrateOnProximity: vibrateOnProximity ?? this.vibrateOnProximity,
      sensorSensitivity: sensorSensitivity ?? this.sensorSensitivity,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  late SharedPreferences _prefs;

  SettingsNotifier() : super(SettingsState.initial());

  /// Inicializa o notifier com SharedPreferences
  Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
    await _loadSettings();
  }

  /// Carrega as configurações salvas
  Future<void> _loadSettings() async {
    try {
      final autoStart = _prefs.getBool(AppConstants.keyAutoStartOnBoot) ?? false;
      final showNotification = _prefs.getBool(AppConstants.keyShowPersistentNotification) ?? true;
      final vibrate = _prefs.getBool(AppConstants.keyVibrateOnProximity) ?? false;
      final sensitivity = _prefs.getDouble(AppConstants.keySensorSensitivity) 
          ?? AppConstants.defaultSensitivity;

      state = SettingsState(
        autoStartOnBoot: autoStart,
        showPersistentNotification: showNotification,
        vibrateOnProximity: vibrate,
        sensorSensitivity: sensitivity,
      );
    } catch (e) {
      print('Erro ao carregar configurações: $e');
    }
  }

  /// Atualiza configuração de inicialização automática
  Future<void> setAutoStartOnBoot(bool value) async {
    await _prefs.setBool(AppConstants.keyAutoStartOnBoot, value);
    state = state.copyWith(autoStartOnBoot: value);
  }

  /// Atualiza configuração de notificação persistente
  Future<void> setShowPersistentNotification(bool value) async {
    await _prefs.setBool(AppConstants.keyShowPersistentNotification, value);
    state = state.copyWith(showPersistentNotification: value);
  }

  /// Atualiza configuração de vibração
  Future<void> setVibrateOnProximity(bool value) async {
    await _prefs.setBool(AppConstants.keyVibrateOnProximity, value);
    state = state.copyWith(vibrateOnProximity: value);
  }

  /// Atualiza sensibilidade do sensor
  Future<void> setSensorSensitivity(double value) async {
    await _prefs.setDouble(AppConstants.keySensorSensitivity, value);
    state = state.copyWith(sensorSensitivity: value);
  }

  /// Reseta todas as configurações para o padrão
  Future<void> resetToDefaults() async {
    await _prefs.setBool(AppConstants.keyAutoStartOnBoot, false);
    await _prefs.setBool(AppConstants.keyShowPersistentNotification, true);
    await _prefs.setBool(AppConstants.keyVibrateOnProximity, false);
    await _prefs.setDouble(AppConstants.keySensorSensitivity, AppConstants.defaultSensitivity);
    
    _loadSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
