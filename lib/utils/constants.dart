/// Constantes globais do aplicativo
class AppConstants {
  // Chaves para SharedPreferences
  static const String keyProtectionEnabled = 'protection_enabled';
  static const String keyAutoStartOnBoot = 'auto_start_on_boot';
  static const String keyShowPersistentNotification = 'show_persistent_notification';
  static const String keyVibrateOnProximity = 'vibrate_on_proximity';
  static const String keySensorSensitivity = 'sensor_sensitivity';
  static const String keyActivationCount = 'activation_count';
  static const String keyLastActivationDate = 'last_activation_date';

  // Configurações do sensor
  static const double defaultSensitivity = 5.0; // cm
  static const double minSensitivity = 1.0;
  static const double maxSensitivity = 10.0;

  // Notificação
  static const int notificationId = 1001;
  static const String notificationChannelId = 'proximity_fix_channel';
  static const String notificationChannelName = 'Proximity Fix Service';

  // Foreground Service
  static const String foregroundServiceTitle = 'Proximity Fix';
  static const String foregroundServiceText = 'Protegendo sua tela do sensor de proximidade';
}
