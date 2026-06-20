import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'providers/sensor_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';

void main() async {
  // Garante que o Flutter esteja totalmente inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Configura o modo de sistema para imersivo (opcional, melhora experiência)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Define cores da barra de status e navegação
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // Fornece o SharedPreferences inicializado para os providers
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ProximityFixApp(),
    ),
  );
}
