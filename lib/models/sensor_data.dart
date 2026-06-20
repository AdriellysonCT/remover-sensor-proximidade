/// Modelo para dados do sensor de proximidade
class SensorData {
  final double distance; // Distância em cm
  final DateTime timestamp;
  final bool isNear; // true se o sensor detecta proximidade

  const SensorData({
    required this.distance,
    required this.timestamp,
    required this.isNear,
  });

  /// Cria uma instância a partir dos valores brutos do sensor
  factory SensorData.fromRawValue(double distance) {
    // A maioria dos sensores retorna 0.0 quando algo está próximo e > 0 quando distante
    // Alguns retornam valores específicos como 1.0 (perto) e 5.0 (distante)
    final isNear = distance == 0.0 || distance < 1.0;
    
    return SensorData(
      distance: distance,
      timestamp: DateTime.now(),
      isNear: isNear,
    );
  }

  /// Retorna o status formatado para exibição
  String get statusText {
    return isNear ? 'Próximo ⚠️' : 'Distante ✅';
  }

  /// Retorna a cor associada ao status
  String get statusColor {
    return isNear ? 'warning' : 'success';
  }

  @override
  String toString() {
    return 'SensorData(distance: $distance cm, isNear: $isNear, time: ${timestamp.toIso8601String()})';
  }

  /// Compara com outro SensorData
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SensorData &&
        other.distance == distance &&
        other.isNear == isNear;
  }

  @override
  int get hashCode => distance.hashCode ^ isNear.hashCode;
}

/// Modelo para estatísticas de uso
class UsageStats {
  final int activationCount; // Quantas vezes o sensor foi ativado hoje
  final DateTime lastActivationDate;
  final List<SensorData> recentActivations;

  const UsageStats({
    required this.activationCount,
    required this.lastActivationDate,
    required this.recentActivations,
  });

  factory UsageStats.empty() {
    return UsageStats(
      activationCount: 0,
      lastActivationDate: DateTime.now(),
      recentActivations: [],
    );
  }

  /// Verifica se é um novo dia e reseta o contador se necessário
  UsageStats checkNewDay() {
    final now = DateTime.now();
    final lastDate = DateTime(
      lastActivationDate.year,
      lastActivationDate.month,
      lastActivationDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    if (today.isAfter(lastDate)) {
      // Novo dia, reseta o contador
      return copyWith(
        activationCount: 0,
        lastActivationDate: now,
        recentActivations: [],
      );
    }

    return this;
  }

  /// Incrementa o contador de ativações
  UsageStats incrementActivation(SensorData data) {
    final newActivations = List<SensorData>.from(recentActivations)..add(data);
    // Mantém apenas as últimas 100 ativações
    if (newActivations.length > 100) {
      newActivations.removeAt(0);
    }

    return copyWith(
      activationCount: activationCount + 1,
      lastActivationDate: DateTime.now(),
      recentActivations: newActivations,
    );
  }

  UsageStats copyWith({
    int? activationCount,
    DateTime? lastActivationDate,
    List<SensorData>? recentActivations,
  }) {
    return UsageStats(
      activationCount: activationCount ?? this.activationCount,
      lastActivationDate: lastActivationDate ?? this.lastActivationDate,
      recentActivations: recentActivations ?? this.recentActivations,
    );
  }

  @override
  String toString() {
    return 'UsageStats(activations: $activationCount, lastDate: ${lastActivationDate.toIso8601String()})';
  }
}
