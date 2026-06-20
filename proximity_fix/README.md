# 📱 Proximity Fix

Aplicativo Flutter para resolver problemas com sensor de proximidade defeituoso no Android.

## 🎯 Problema Resolvido

Quando o sensor de proximidade do Android está com defeito, ao ouvir áudios no WhatsApp, 
a tela se apaga mesmo sem nada próximo, forçando o usuário a encostar o celular no ouvido.

## ✅ Solução

Este aplicativo mantém a tela SEMPRE LIGADA através de WakeLock e monitora o sensor de 
proximidade, impedindo que o sistema apague a tela quando o sensor for ativado.

## 🚀 Funcionalidades

- **Proteção de Tela**: Mantém a tela ligada usando WakeLock
- **Monitoramento em Tempo Real**: Lê o sensor de proximidade continuamente
- **Serviço em Background**: Roda como Foreground Service com notificação persistente
- **Início Automático**: Pode iniciar automaticamente ao ligar o celular
- **Estatísticas**: Conta quantas vezes o sensor foi ativado
- **Teste de Sensor**: Tela dedicada para testar e visualizar valores do sensor

## 📋 Requisitos

- Flutter SDK >= 3.0.0
- Android API 21+ (Android 5.0)
- Android 13+ requer permissão de notificação explícita

## 🔧 Instalação

### 1. Clonar ou copiar o projeto

```bash
cd proximity_fix
```

### 2. Instalar dependências

```bash
flutter pub get
```

### 3. Gerar código do Riverpod (se necessário)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configurar permissões (já configurado no AndroidManifest.xml)

As seguintes permissões são necessárias:
- `WAKE_LOCK` - Manter tela ligada
- `FOREGROUND_SERVICE` - Executar serviço em background
- `FOREGROUND_SERVICE_SPECIAL_USE` - Android 14+
- `POST_NOTIFICATIONS` - Android 13+
- `RECEIVE_BOOT_COMPLETED` - Iniciar após boot

### 5. Compilar APK de Release

```bash
flutter build apk --release
```

O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

### 6. Compilar App Bundle (para Play Store)

```bash
flutter build appbundle --release
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do app
├── screens/
│   ├── home_screen.dart      # Tela principal
│   ├── settings_screen.dart  # Configurações
│   └── sensor_test_screen.dart # Teste do sensor
├── services/
│   ├── proximity_service.dart # Serviço de proximidade
│   └── notification_service.dart # Notificações
├── providers/
│   ├── app_provider.dart     # Estado global do app
│   ├── sensor_provider.dart  # Estado do sensor
│   └── settings_provider.dart # Configurações
├── widgets/
│   ├── protection_toggle.dart # Botão de ativação
│   ├── sensor_status_card.dart # Status do sensor
│   ├── stats_card.dart       # Estatísticas
│   └── custom_slider.dart    # Slider personalizado
└── utils/
    ├── constants.dart        # Constantes do app
    └── permissions_helper.dart # Helper de permissões
```

## 🎨 Design

- **Material 3** com tema escuro por padrão
- **Cor Primária**: Azul Ciano (#00BCD4)
- **Verde**: Indica estado ativo
- **Vermelho**: Indica estado inativo

## ⚙️ Como Funciona

1. Usuário ativa a proteção
2. App solicita permissões necessárias
3. WakeLock é ativado (tela não apaga)
4. Foreground Service é iniciado
5. Sensor de proximidade é monitorado
6. Quando sensor detecta proximidade, WakeLock é mantido ativo
7. Notificação persistente mostra que proteção está ativa

## 🔐 Permissões

Na primeira execução, o app solicitará:
- Permissão para mostrar notificações (Android 13+)
- Permissão para ignorar otimizações de bateria (opcional, recomendado)

## 🛠️ Troubleshooting

### O serviço não inicia automaticamente
- Verifique se a opção "Iniciar automaticamente" está ativada
- Alguns fabricantes (Xiaomi, Huawei) requerem configuração adicional
- Conceda permissão de "Início automático" nas configurações do sistema

### Notificação não aparece
- Android 13+: conceda permissão de notificação manualmente
- Verifique se as notificações do app não estão bloqueadas

### Sensor não responde
- Use a tela "Testar Sensor" para verificar se o hardware funciona
- Alguns dispositivos têm sensores digitais (0 ou 1) em vez de analógicos

## 📝 Licença

MIT License

## 👨‍💻 Desenvolvedor

Desenvolvido com Flutter e Dart usando arquitetura MVVM e Riverpod.
