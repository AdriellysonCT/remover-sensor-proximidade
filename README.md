# Proximity Fix - Aplicativo Flutter

## 📱 Descrição

O **Proximity Fix** é um aplicativo Flutter desenvolvido para resolver problemas com sensores de proximidade defeituosos em dispositivos Android. 

### Problema que resolve:
Quando o sensor de proximidade está com defeito, ao ouvir áudios no WhatsApp (ou em outros apps), a tela se apaga mesmo sem nada próximo do sensor, forçando o usuário a encostar o celular no ouvido como se fosse uma ligação telefônica.

### Solução técnica:
O app mantém a tela SEMPRE LIGADA através de WakeLock e monitora o sensor de proximidade, impedindo que o sistema operacional apague a tela quando o sensor for ativado indevidamente.

---

## 🏗️ Arquitetura

- **Flutter** (versão estável mais recente)
- **Dart** com Null Safety
- **Gerenciamento de estado:** Riverpod
- **Arquitetura:** MVVM simples
- **Roteamento:** GoRouter

### Dependências principais:
- `wakelock_plus` - Mantém a tela ligada
- `sensors_plus` - Lê o sensor de proximidade
- `flutter_foreground_task` - Roda em background com notificação persistente
- `permission_handler` - Solicita permissões do sistema
- `shared_preferences` - Salva preferências do usuário
- `go_router` - Navegação entre telas
- `vibration` - Feedback tátil
- `fl_chart` - Gráfico de testes do sensor

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do app
├── app.dart                  # Widget principal e rotas
├── utils/
│   ├── constants.dart        # Constantes globais
│   ├── theme.dart            # Tema Material 3
│   └── permissions_helper.dart # Gerenciador de permissões
├── models/
│   └── sensor_data.dart      # Modelos de dados
├── providers/
│   ├── app_provider.dart     # Estado global do app
│   ├── sensor_provider.dart  # Estado do sensor
│   ├── settings_provider.dart # Configurações
│   └── stats_provider.dart   # Estatísticas de uso
├── services/
│   ├── wake_lock_service.dart # Controle do WakeLock
│   ├── proximity_service.dart # Serviço em foreground
│   └── sensor_monitor_service.dart # Monitoramento do sensor
├── widgets/                  # Widgets reutilizáveis
│   ├── protection_toggle.dart
│   ├── sensor_status_card.dart
│   ├── wake_lock_status_card.dart
│   ├── service_status_card.dart
│   ├── stats_card.dart
│   ├── custom_slider.dart
│   └── animated_indicator.dart
└── screens/                  # Telas do app
    ├── home_screen.dart
    ├── settings_screen.dart
    └── sensor_test_screen.dart
```

---

## 🔧 Instalação e Build

### Pré-requisitos:
- Flutter SDK 3.0+ instalado
- Android Studio ou VS Code com extensão Flutter
- Dispositivo Android ou emulador

### Passos para compilar:

1. **Clone ou navegue até o diretório do projeto:**
```bash
cd /workspace
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Verifique a configuração do Flutter:**
```bash
flutter doctor
```

4. **Compile o APK de release:**
```bash
flutter build apk --release
```

5. **Ou compile um App Bundle para Play Store:**
```bash
flutter build appbundle --release
```

### Onde encontrar o APK:
O APK gerado estará em:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 Como Usar

### Tela Principal:
1. Toque no botão grande **"ATIVAR PROTEÇÃO"** para iniciar
2. O app mostrará:
   - Status do sensor em tempo real
   - Status do WakeLock (ATIVO/INATIVO)
   - Status do serviço em background
   - Contador de ativações do sensor

### Configurações:
- **Iniciar ao ligar:** Ativa automaticamente após boot
- **Notificação persistente:** Mantém o serviço rodando
- **Vibrar ao detectar:** Feedback tátil quando sensor ativa
- **Sensibilidade:** Ajusta o threshold de detecção (1-10 cm)

### Testar Sensor:
- Mostra valores brutos do sensor
- Gráfico em tempo real da variação
- Útil para diagnosticar se o sensor está realmente com defeito

---

## 🔐 Permissões Necessárias

O app solicita as seguintes permissões no AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

### Nota sobre Android 13+:
- A permissão `POST_NOTIFICATIONS` é obrigatória para Android 13+
- O app solicita esta permissão na primeira execução

---

## ⚙️ Funcionamento Técnico

### Quando a proteção é ativada:

1. **WakeLock é ativado** - Mantém a tela ligada
2. **Foreground Service inicia** - Com notificação persistente
3. **Sensor é monitorado** - Via stream do sensors_plus
4. **Estado é persistido** - No SharedPreferences

### Quando a proteção é desativada:

1. **WakeLock é liberado**
2. **Serviço é parado**
3. **Notificação é cancelada**

---

## 🎨 UI/UX

- **Material 3** design system
- **Tema escuro** por padrão (economiza bateria em OLED)
- **Cores:** 
  - Primária: Azul ciano (#00BCD4)
  - Sucesso: Verde (#4CAF50)
  - Erro: Vermelho (#F44336)
  - Alerta: Laranja (#FF9800)
- **Animações suaves** nos toggles e indicadores
- **Feedback tátil** (HapticFeedback) nas interações

---

## 🐛 Tratamento de Erros

O código inclui tratamento robusto de erros:
- Try/catch em todas as chamadas de sistema
- Verificação de permissões negadas
- Fallbacks para estados seguros em caso de falha
- Mensagens informativas para o usuário

---

## 📋 Notas Importantes

1. **Bateria:** Manter a tela ligada consome mais bateria. Use apenas quando necessário.

2. **Otimização de Bateria:** Alguns fabricantes (Xiaomi, Samsung, etc.) podem encerrar o serviço em background. Recomenda-se:
   - Adicionar o app à lista de "Não otimizar"
   - Conceder permissão de "Execução em segundo plano"

3. **Compatibilidade:** Testado principalmente em Android 10+. Funciona em Android 8+ com limitações.

---

## 📄 Licença

Este projeto é fornecido "como está" para fins educacionais e de uso pessoal.

---

## 👨‍💻 Desenvolvedor

Desenvolvido como solução para usuários com sensores de proximidade defeituosos.