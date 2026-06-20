import 'package:wakelock_plus/wakelock_plus.dart';

/// Serviço para gerenciar o WakeLock e manter a tela ligada
class WakeLockService {
  static bool _isWakeLockActive = false;

  /// Verifica se o WakeLock está ativo
  static bool get isWakeLockActive => _isWakeLockActive;

  /// Ativa o WakeLock para manter a tela ligada
  static Future<bool> enable() async {
    try {
      // Ativa o wakelock para manter a tela ligada
      await WakelockPlus.enable();
      _isWakeLockActive = true;
      print('WakeLock ativado com sucesso');
      return true;
    } catch (e) {
      print('Erro ao ativar WakeLock: $e');
      _isWakeLockActive = false;
      return false;
    }
  }

  /// Desativa o WakeLock
  static Future<bool> disable() async {
    try {
      // Desativa o wakelock
      await WakelockPlus.disable();
      _isWakeLockActive = false;
      print('WakeLock desativado com sucesso');
      return true;
    } catch (e) {
      print('Erro ao desativar WakeLock: $e');
      return false;
    }
  }

  /// Alterna o estado do WakeLock
  static Future<bool> toggle() async {
    if (_isWakeLockActive) {
      return await disable();
    } else {
      return await enable();
    }
  }

  /// Verifica o status atual do WakeLock
  static Future<bool> checkStatus() async {
    try {
      // O wakelock_plus não tem um método direto para verificar status
      // Então retornamos nosso estado interno
      return _isWakeLockActive;
    } catch (e) {
      print('Erro ao verificar status do WakeLock: $e');
      return false;
    }
  }

  /// Reinicializa o serviço (útil após boot ou retomada do app)
  static Future<void> reinitialize() async {
    try {
      // Garante que o wakelock está em um estado conhecido
      await WakelockPlus.disable();
      _isWakeLockActive = false;
    } catch (e) {
      print('Erro ao reinicializar WakeLock: $e');
    }
  }
}
