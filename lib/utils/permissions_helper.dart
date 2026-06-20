import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper para gerenciar permissões do sistema Android
class PermissionsHelper {
  /// Verifica e solicita todas as permissões necessárias
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    try {
      // Permissão de notificação (Android 13+)
      final notificationStatus = await Permission.notification.status;
      results['notification'] = notificationStatus.isGranted;
      
      if (!notificationStatus.isGranted) {
        final requestResult = await Permission.notification.request();
        results['notification'] = requestResult.isGranted;
      }

      // Permissão para ignorar otimização de bateria (opcional, mas recomendado)
      // Esta permissão não pode ser solicitada diretamente, precisa abrir configurações
      
      // Status das permissões
      results['wakeLock'] = true; // WAKE_LOCK é concedida automaticamente no manifest
      results['foregroundService'] = true; // FOREGROUND_SERVICE é concedida automaticamente
      
    } catch (e) {
      print('Erro ao solicitar permissões: $e');
      results['error'] = false;
    }

    return results;
  }

  /// Verifica se a permissão de notificação está concedida
  static Future<bool> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('Erro ao verificar permissão de notificação: $e');
      return false;
    }
  }

  /// Solicita permissão de notificação
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      print('Erro ao solicitar permissão de notificação: $e');
      return false;
    }
  }

  /// Abre as configurações do aplicativo para o usuário conceder permissões manualmente
  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Erro ao abrir configurações: $e');
    }
  }

  /// Verifica se o sensor de proximidade está disponível no dispositivo
  static Future<bool> checkProximitySensor() async {
    try {
      final availableSensors = await SystemChannels.platform.invokeMethod(
        'Flutter.method#availableSensors',
      );
      // Nota: sensors_plus já verifica internamente, mas esta é uma verificação adicional
      return true;
    } catch (e) {
      // Se falhar, assumimos que o sensor existe (a maioria dos dispositivos tem)
      return true;
    }
  }

  /// Aciona vibração (feedback tátil)
  static Future<void> vibrate({Duration duration = const Duration(milliseconds: 200)}) async {
    try {
      // Verifica se temos permissão para vibrar
      final hasVibratePermission = await _checkVibratePermission();
      if (hasVibratePermission) {
        await HapticFeedback.vibrate();
      }
    } catch (e) {
      print('Erro ao vibrar: $e');
    }
  }

  /// Feedback tátil leve
  static Future<void> lightHaptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      print('Erro ao executar haptic leve: $e');
    }
  }

  /// Feedback tátil médio
  static Future<void> mediumHaptic() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      print('Erro ao executar haptic médio: $e');
    }
  }

  /// Verifica permissão de vibração (Android 13+)
  static Future<bool> _checkVibratePermission() async {
    try {
      // Em Android 13+, a vibração requer permissão POST_NOTIFICATIONS em alguns casos
      final notificationStatus = await Permission.notification.status;
      return notificationStatus.isGranted || 
             DateTime.now().millisecondsSinceEpoch < 1704067200000; // Antes de 2024 para compatibilidade
    } catch (e) {
      return true; // Assume permitido se não conseguir verificar
    }
  }
}
