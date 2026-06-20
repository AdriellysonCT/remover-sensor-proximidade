import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../providers/sensor_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../services/wake_lock_service.dart';
import '../services/proximity_service.dart';
import '../utils/permissions_helper.dart';
import '../widgets/protection_toggle.dart';
import '../widgets/sensor_status_card.dart';
import '../widgets/wake_lock_status_card.dart';
import '../widgets/service_status_card.dart';
import '../widgets/stats_card.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../models/sensor_data.dart';

/// Tela principal do aplicativo
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isProtectionEnabled = false;
  bool _serviceRunning = false;
  bool _wakeLockActive = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Inicializa o aplicativo
  Future<void> _initializeApp() async {
    // Solicita permissões necessárias
    await PermissionsHelper.requestAllPermissions();
    
    // Inicializa o serviço em foreground
    await ProximityForegroundService.initialize();
    
    // Verifica se o serviço já estava rodando
    final wasRunning = await ProximityForegroundService.isRunning();
    if (wasRunning) {
      setState(() {
        _serviceRunning = true;
        _isProtectionEnabled = true;
      });
    }
  }

  /// Alterna o estado da proteção
  Future<void> _toggleProtection(bool enable) async {
    try {
      if (enable) {
        // Ativar proteção
        final wakeLockSuccess = await WakeLockService.enable();
        if (!wakeLockSuccess) {
          _showErrorSnackBar('Falha ao ativar WakeLock');
          return;
        }

        // Inicia serviço em foreground
        final serviceStarted = await ProximityForegroundService.startService(
          title: AppConstants.foregroundServiceTitle,
          content: AppConstants.foregroundServiceText,
        );

        if (!serviceStarted) {
          await WakeLockService.disable();
          _showErrorSnackBar('Falha ao iniciar serviço em background');
          return;
        }

        // Inicia monitoramento do sensor
        final sensorNotifier = ref.read(sensorProvider.notifier);
        final monitoringStarted = await sensorNotifier.startMonitoring();

        if (!monitoringStarted) {
          await WakeLockService.disable();
          await ProximityForegroundService.stopService();
          _showErrorSnackBar('Falha ao iniciar monitoramento do sensor');
          return;
        }

        setState(() {
          _isProtectionEnabled = true;
          _serviceRunning = true;
          _wakeLockActive = true;
        });

        // Feedback tátil
        await PermissionsHelper.mediumHaptic();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proteção ativada com sucesso!'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Desativar proteção
        await WakeLockService.disable();
        await ProximityForegroundService.stopService();
        
        final sensorNotifier = ref.read(sensorProvider.notifier);
        await sensorNotifier.stopMonitoring();

        setState(() {
          _isProtectionEnabled = false;
          _serviceRunning = false;
          _wakeLockActive = false;
        });

        // Feedback tátil
        await PermissionsHelper.lightHaptic();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proteção desativada'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao alternar proteção: $e');
      _showErrorSnackBar('Erro: ${e.toString()}');
      
      // Garante que tudo está desativado em caso de erro
      setState(() {
        _isProtectionEnabled = false;
        _serviceRunning = false;
        _wakeLockActive = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensorState = ref.watch(sensorProvider);
    final statsState = ref.watch(statsProvider);
    final settingsState = ref.watch(settingsProvider);

    // Registra ativações quando o sensor detecta proximidade
    if (sensorState.isNear && _isProtectionEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(statsProvider.notifier).registerActivation(
          SensorData(
            distance: sensorState.distance,
            timestamp: DateTime.now(),
            isNear: true,
          ),
        );
        
        // Vibra se configurado
        if (settingsState.vibrateOnProximity) {
          PermissionsHelper.vibrate();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proximity Fix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Toggle principal
            ProtectionToggle(
              isEnabled: _isProtectionEnabled,
              onChanged: _toggleProtection,
            ),
            const SizedBox(height: 32),
            
            // Status do sensor
            SensorStatusCard(
              distance: sensorState.distance,
              isNear: sensorState.isNear,
              isMonitoring: sensorState.isMonitoring,
            ),
            const SizedBox(height: 16),
            
            // Status do WakeLock
            WakeLockStatusCard(isActive: _wakeLockActive),
            const SizedBox(height: 16),
            
            // Status do serviço
            ServiceStatusCard(isRunning: _serviceRunning),
            const SizedBox(height: 16),
            
            // Estatísticas
            StatsCard(
              activationCount: statsState.activationCount,
              lastActivation: statsState.lastActivationDate,
            ),
            const SizedBox(height: 16),
            
            // Botão para tela de teste
            ElevatedButton.icon(
              onPressed: () => context.push('/sensor-test'),
              icon: const Icon(Icons.bug_report),
              label: const Text('Testar Sensor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
