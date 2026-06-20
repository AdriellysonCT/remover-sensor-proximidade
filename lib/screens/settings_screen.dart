import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../services/proximity_service.dart';
import '../utils/permissions_helper.dart';
import '../widgets/custom_slider.dart';
import '../utils/theme.dart';

/// Tela de configurações do aplicativo
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção: Comportamento
            _buildSectionTitle('Comportamento'),
            const SizedBox(height: 8),
            
            // Iniciar automaticamente
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.power_settings_new,
                  color: AppTheme.primaryColor,
                ),
                title: const Text('Iniciar ao ligar o celular'),
                subtitle: const Text(
                  'Ativa a proteção automaticamente quando o dispositivo é iniciado',
                ),
                trailing: Switch(
                  value: settings.autoStartOnBoot,
                  onChanged: (value) {
                    settingsNotifier.setAutoStartOnBoot(value);
                    PermissionsHelper.lightHaptic();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Notificação persistente
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.notifications_active,
                  color: AppTheme.primaryColor,
                ),
                title: const Text('Notificação persistente'),
                subtitle: const Text(
                  'Mostra notificação para manter o serviço em background',
                ),
                trailing: Switch(
                  value: settings.showPersistentNotification,
                  onChanged: (value) async {
                    await settingsNotifier.setShowPersistentNotification(value);
                    PermissionsHelper.lightHaptic();
                    
                    if (!value) {
                      _showWarningDialog(
                        'Desativar a notificação pode fazer com que o sistema Android encerre o serviço em background.',
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Vibração
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.vibration,
                  color: AppTheme.primaryColor,
                ),
                title: const Text('Vibrar ao detectar proximidade'),
                subtitle: const Text(
                  'Fornece feedback tátil quando o sensor detecta algo próximo',
                ),
                trailing: Switch(
                  value: settings.vibrateOnProximity,
                  onChanged: (value) async {
                    await settingsNotifier.setVibrateOnProximity(value);
                    PermissionsHelper.lightHaptic();
                    
                    if (value) {
                      // Testa vibração
                      PermissionsHelper.vibrate();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seção: Sensor
            _buildSectionTitle('Sensor'),
            const SizedBox(height: 8),

            // Slider de sensibilidade
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomSensitivitySlider(
                  value: settings.sensorSensitivity,
                  min: AppConstants.minSensitivity,
                  max: AppConstants.maxSensitivity,
                  onChanged: (value) {
                    settingsNotifier.setSensorSensitivity(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seção: Ações
            _buildSectionTitle('Ações'),
            const SizedBox(height: 8),

            // Botão: Testar sensor
            ElevatedButton.icon(
              onPressed: () => context.push('/sensor-test'),
              icon: const Icon(Icons.bug_report),
              label: const Text('Testar Sensor'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),

            // Botão: Configurações de bateria
            ElevatedButton.icon(
              onPressed: () async {
                await ProximityForegroundService.openBatterySettings();
              },
              icon: const Icon(Icons.battery_charging_full),
              label: const Text('Otimização de Bateria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),

            // Botão: Configurações de notificação
            ElevatedButton.icon(
              onPressed: () async {
                await ProximityForegroundService.openNotificationSettings();
              },
              icon: const Icon(Icons.notification_add),
              label: const Text('Configurar Notificações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),

            // Seção: Sobre
            _buildSectionTitle('Sobre'),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proximity Fix',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Versão 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Este aplicativo mantém sua tela ligada quando o sensor de proximidade é ativado, resolvendo problemas com sensores defeituosos.',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atenção'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
