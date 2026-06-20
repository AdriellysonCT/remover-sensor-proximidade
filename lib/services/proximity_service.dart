import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Serviço em background para monitorar o sensor de proximidade
/// Este serviço roda em primeiro plano com notificação persistente
class ProximityForegroundService {
  static const String channelId = 'proximity_fix_channel';
  static const String channelName = 'Proximity Fix Service';
  
  /// Inicializa o serviço em foreground
  static Future<void> initialize() async {
    // Configurações do serviço em foreground
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: channelId,
        channelName: channelName,
        channelDescription: 'Mantém a proteção contra o sensor de proximidade ativa',
        channelImportance: NotificationChannelImportance.LOW,
        showWhen: true,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        interval: 5000, // Atualiza a cada 5 segundos
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Inicia o serviço em foreground
  static Future<bool> startService({
    required String title,
    required String content,
  }) async {
    try {
      // Define o conteúdo da notificação
      await FlutterForegroundTask.setNotificationData(
        title: title,
        content: content,
      );

      // Inicia o serviço
      await FlutterForegroundTask.startService(
        notificationTitle: title,
        notificationText: content,
      );
      
      return true;
    } catch (e) {
      print('Erro ao iniciar serviço em foreground: $e');
      return false;
    }
  }

  /// Para o serviço em foreground
  static Future<void> stopService() async {
    try {
      await FlutterForegroundTask.stopService();
    } catch (e) {
      print('Erro ao parar serviço em foreground: $e');
    }
  }

  /// Verifica se o serviço está rodando
  static Future<bool> isRunning() async {
    try {
      return await FlutterForegroundTask.isRunningService;
    } catch (e) {
      print('Erro ao verificar status do serviço: $e');
      return false;
    }
  }

  /// Atualiza o conteúdo da notificação
  static Future<void> updateNotification({
    required String title,
    required String content,
  }) async {
    try {
      await FlutterForegroundTask.setNotificationData(
        title: title,
        content: content,
      );
    } catch (e) {
      print('Erro ao atualizar notificação: $e');
    }
  }

  /// Solicita permissão para ignorar otimização de bateria
  static Future<void> requestIgnoreBatteryOptimization() async {
    try {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    } catch (e) {
      print('Erro ao solicitar ignorar otimização de bateria: $e');
    }
  }

  /// Abre configurações de bateria
  static Future<void> openBatterySettings() async {
    try {
      await FlutterForegroundTask.openBatteryOptimizationSettings();
    } catch (e) {
      print('Erro ao abrir configurações de bateria: $e');
    }
  }

  /// Abre configurações de notificação
  static Future<void> openNotificationSettings() async {
    try {
      await FlutterForegroundTask.openNotificationSettings();
    } catch (e) {
      print('Erro ao abrir configurações de notificação: $e');
    }
  }
}
