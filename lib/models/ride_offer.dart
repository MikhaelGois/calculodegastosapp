// ignore_for_file: constant_identifier_names

enum RideApp { UBER, NINETY_NINE, INDRIVE, UNKNOWN }

enum TrafficLight { GREEN, YELLOW, RED }

/// Modelo para oferta de corrida detectada em notificações
class RideOffer {
  final String id;
  final RideApp app;
  final String? pickupLocation;
  final String? dropoffLocation;
  final double? distanceKm;
  final double? estimatedTimeMinutes;
  final double? offeredValue;
  final DateTime detectedAt;
  final TrafficLight trafficLight;
  final String trafficLightReason;
  final double profitabilityScore; // 0-100

  RideOffer({
    required this.id,
    required this.app,
    this.pickupLocation,
    this.dropoffLocation,
    this.distanceKm,
    this.estimatedTimeMinutes,
    this.offeredValue,
    required this.detectedAt,
    required this.trafficLight,
    required this.trafficLightReason,
    required this.profitabilityScore,
  });

  /// Retorna o nome legível do app
  String get appName {
    switch (app) {
      case RideApp.UBER:
        return 'Uber';
      case RideApp.NINETY_NINE:
        return '99';
      case RideApp.INDRIVE:
        return 'inDriver';
      case RideApp.UNKNOWN:
        return 'Desconhecido';
    }
  }

  /// Retorna o ícone do app
  String get appIcon {
    switch (app) {
      case RideApp.UBER:
        return '🚗'; // ou outro ícone
      case RideApp.NINETY_NINE:
        return '9️⃣'; // ou 99
      case RideApp.INDRIVE:
        return '🔵';
      case RideApp.UNKNOWN:
        return '❓';
    }
  }

  /// Retorna emoji do semáforo
  String get trafficLightEmoji {
    switch (trafficLight) {
      case TrafficLight.GREEN:
        return '🟢';
      case TrafficLight.YELLOW:
        return '🟡';
      case TrafficLight.RED:
        return '🔴';
    }
  }

  /// Retorna color para UI
  String get trafficLightColor {
    switch (trafficLight) {
      case TrafficLight.GREEN:
        return '#22C55E'; // green-500
      case TrafficLight.YELLOW:
        return '#EAB308'; // yellow-500
      case TrafficLight.RED:
        return '#EF4444'; // red-500
    }
  }

  /// Retorna mensagem legível do semáforo
  String get trafficLightMessage {
    switch (trafficLight) {
      case TrafficLight.GREEN:
        return 'ÓTIMA OPORTUNIDADE - Aceitar!';
      case TrafficLight.YELLOW:
        return 'Pensar bem antes de aceitar';
      case TrafficLight.RED:
        return 'NÃO RECOMENDADO - Rejeitar';
    }
  }

  /// Retorna recomendação com razão
  String get recommendation {
    return '$trafficLightEmoji $trafficLightMessage\n$trafficLightReason';
  }

  /// Serialização para armazenamento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'app': app.toString(),
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'distanceKm': distanceKm,
      'estimatedTimeMinutes': estimatedTimeMinutes,
      'offeredValue': offeredValue,
      'detectedAt': detectedAt.toIso8601String(),
      'trafficLight': trafficLight.toString(),
      'trafficLightReason': trafficLightReason,
      'profitabilityScore': profitabilityScore,
    };
  }

  /// Desserialização
  factory RideOffer.fromMap(Map<String, dynamic> map) {
    return RideOffer(
      id: map['id'] as String,
      app: _parseRideApp(map['app'] as String),
      pickupLocation: map['pickupLocation'] as String?,
      dropoffLocation: map['dropoffLocation'] as String?,
      distanceKm: map['distanceKm'] as double?,
      estimatedTimeMinutes: map['estimatedTimeMinutes'] as double?,
      offeredValue: map['offeredValue'] as double?,
      detectedAt: DateTime.parse(map['detectedAt'] as String),
      trafficLight: _parseTrafficLight(map['trafficLight'] as String),
      trafficLightReason: map['trafficLightReason'] as String,
      profitabilityScore: map['profitabilityScore'] as double,
    );
  }

  static RideApp _parseRideApp(String value) {
    switch (value) {
      case 'RideApp.UBER':
        return RideApp.UBER;
      case 'RideApp.NINETY_NINE':
        return RideApp.NINETY_NINE;
      case 'RideApp.INDRIVE':
        return RideApp.INDRIVE;
      default:
        return RideApp.UNKNOWN;
    }
  }

  static TrafficLight _parseTrafficLight(String value) {
    switch (value) {
      case 'TrafficLight.GREEN':
        return TrafficLight.GREEN;
      case 'TrafficLight.YELLOW':
        return TrafficLight.YELLOW;
      case 'TrafficLight.RED':
        return TrafficLight.RED;
      default:
        return TrafficLight.YELLOW;
    }
  }
}
