# Proguard rules para o Proximity Fix
# Mantém classes necessárias para o funcionamento do app

# Manter classes do Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Manter classes do wakelock_plus
-keep class com.baseflow.wakelock.** { *; }

# Manter classes do flutter_foreground_task
-keep class com.pravera.flutter_foreground_task.** { *; }

# Manter classes do sensors_plus
-keep class io.flutter.plugins.sensors.** { *; }

# Manter classes do permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# Manter classes do shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Manter classes geradas pelo Riverpod
-keep class **/**.g.dart { *; }

# Regras gerais
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
