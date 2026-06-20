package com.example.proximity_fix

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Receiver que é acionado quando o dispositivo é inicializado.
 * Usado para iniciar automaticamente o serviço de proteção se configurado.
 */
class BootReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        // Verifica se a ação é BOOT_COMPLETED
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent.action == "com.htc.intent.action.QUICKBOOT_POWERON") {
            
            Log.d("BootReceiver", "Dispositivo foi inicializado")
            
            try {
                // Obtém preferências salvas
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val autoStart = prefs.getBoolean("flutter.auto_start_on_boot", false)
                
                Log.d("BootReceiver", "Auto-start configurado: $autoStart")
                
                if (autoStart) {
                    // Inicia a atividade principal
                    val launchIntent = Intent(context, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        putExtra("auto_start", true)
                    }
                    context.startActivity(launchIntent)
                    
                    Log.d("BootReceiver", "Aplicação iniciada automaticamente")
                }
            } catch (e: Exception) {
                Log.e("BootReceiver", "Erro ao iniciar automaticamente: ${e.message}")
            }
        }
    }
}
