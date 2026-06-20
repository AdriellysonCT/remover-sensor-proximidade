import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Provider para gerenciar o estado global do aplicativo
class AppState {
  final bool isInitialized;
  final bool hasNotificationPermission;

  const AppState({
    required this.isInitialized,
    required this.hasNotificationPermission,
  });

  AppState copyWith({
    bool? isInitialized,
    bool? hasNotificationPermission,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasNotificationPermission: hasNotificationPermission ?? this.hasNotificationPermission,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState(isInitialized: false, hasNotificationPermission: false));

  /// Inicializa o aplicativo
  Future<void> initialize() async {
    try {
      // Verifica permissão de notificação
      final hasPermission = await _checkNotificationPermission();
      state = state.copyWith(
        isInitialized: true,
        hasNotificationPermission: hasPermission,
      );
    } catch (e) {
      print('Erro ao inicializar app: $e');
      state = state.copyWith(isInitialized: true);
    }
  }

  /// Verifica permissão de notificação
  Future<bool> _checkNotificationPermission() async {
    // Implementação simplificada - será tratada no permissions_helper
    return true;
  }

  /// Atualiza status da permissão de notificação
  void updateNotificationPermission(bool hasPermission) {
    state = state.copyWith(hasNotificationPermission: hasPermission);
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});

/// Provider para acesso ao SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Deve ser inicializado no main.dart');
});
