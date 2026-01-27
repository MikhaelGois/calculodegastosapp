import 'package:uuid/uuid.dart';
import '../models/ride_offer.dart';
import '../models/vehicle.dart';
import 'calculation_service.dart' as _calc;

/// Resultado da análise de semáforo
class TrafficLightResult {
  final TrafficLight light;
  final String reason;
  final double score;

  TrafficLightResult({
    required this.light,
    required this.reason,
    required this.score,
  });
}

/// Serviço para detectar e analisar notificações de corridas de apps de ride-sharing
class RideNotificationService {
  /// Detecta qual app enviou a notificação
  static RideApp detectAppFromNotification(
    String title,
    String body, {
    String? packageName,
  }) {
    // Se temos package name, usar para identificação precisa
    if (packageName != null) {
      if (packageName.contains('ubercab')) return RideApp.UBER;
      if (packageName.contains('99taxis')) return RideApp.NINETY_NINE;
      if (packageName.contains('indriver')) return RideApp.INDRIVE;
    }

    // Fallback: procurar keywords no conteúdo
    final content = '$title $body'.toLowerCase();

    if (content.contains('uber')) return RideApp.UBER;
    if (content.contains('99') || content.contains('ninety')) {
      return RideApp.NINETY_NINE;
    }
    if (content.contains('indriver')) {
      return RideApp.INDRIVE;
    }

    return RideApp.UNKNOWN;
  }

  /// Extrai dados da notificação usando regex
  static Map<String, dynamic> extractNotificationData(
    String title,
    String body,
    RideApp app,
  ) {
    final content = '$title $body';

    // Padrões de regex para extração
    final distancePattern = RegExp(r'(\d+(?:,\d+)?)\s*km');
    final valuePattern = RegExp(r'R\$\s*(\d+(?:,\d+)?)');
    final timePattern = RegExp(r'(\d+)\s*min');

    // Extrair distância
    double? distance;
    final distanceMatch = distancePattern.firstMatch(content);
    if (distanceMatch != null) {
      final distanceStr = distanceMatch.group(1)!.replaceAll(',', '.');
      distance = double.tryParse(distanceStr);
    }

    // Extrair valor
    double? value;
    final valueMatch = valuePattern.firstMatch(content);
    if (valueMatch != null) {
      final valueStr = valueMatch.group(1)!.replaceAll(',', '.');
      value = double.tryParse(valueStr);
    }

    // Extrair tempo estimado
    int? time;
    final timeMatch = timePattern.firstMatch(content);
    if (timeMatch != null) {
      time = int.tryParse(timeMatch.group(1)!);
    }

    return {
      'distance': distance,
      'value': value,
      'time': time,
      'pickup': 'Saída',
      'dropoff': 'Destino',
    };
  }

  /// Calcula semáforo baseado em rentabilidade
  static TrafficLightResult calculateTrafficLight(
    RideOffer offer,
    Vehicle vehicle,
  ) {
    if (offer.distanceKm == null || offer.offeredValue == null) {
      return TrafficLightResult(
        light: TrafficLight.YELLOW,
        reason: 'Dados incompletos para análise',
        score: 50.0,
      );
    }

    // Obter valores de referência do veículo
    final calculation = _calc.CalculationService.calculate(vehicle);
    final minValuePerKm = calculation.valuePerKm;
    final minValuePerHour = calculation.valuePerHour;

    double distanceKm = offer.distanceKm!;
    double offeredValue = offer.offeredValue!;
    double estimatedMinutes = offer.estimatedTimeMinutes ?? 20;
    double estimatedHours = estimatedMinutes / 60;

    // Calcular ganho estimado (considerando ~30% de lucro)
    double estimatedProfit = offeredValue * 0.30;

    // Calcular valor por km da oferta
    double valuePerKmOffer = offeredValue / distanceKm;

    // Calcular valor por hora da oferta
    double valuePerHourOffer = offeredValue / estimatedHours;

    // Análise de rentabilidade
    TrafficLight light;
    String reason;
    double score;

    // Critério 1: Valor por km
    final kmComparison = valuePerKmOffer / minValuePerKm;

    // Critério 2: Valor por hora
    final hourComparison = valuePerHourOffer / minValuePerHour;

    // Score de rentabilidade (0-100)
    score = ((kmComparison + hourComparison) / 2) * 50;

    if (kmComparison >= 1.0 && hourComparison >= 1.0 && score >= 70) {
      light = TrafficLight.GREEN;
      reason =
          'Excelente rentabilidade: R\$${valuePerKmOffer.toStringAsFixed(2)}/km, R\$${valuePerHourOffer.toStringAsFixed(2)}/h\nGanho estimado: R\$${estimatedProfit.toStringAsFixed(2)}';
    } else if (kmComparison >= 0.8 && hourComparison >= 0.8 && score >= 50) {
      light = TrafficLight.YELLOW;
      reason =
          'Rentabilidade aceitável: R\$${valuePerKmOffer.toStringAsFixed(2)}/km, R\$${valuePerHourOffer.toStringAsFixed(2)}/h\nGanho estimado: R\$${estimatedProfit.toStringAsFixed(2)}';
    } else {
      light = TrafficLight.RED;
      reason =
          'Baixa rentabilidade: R\$${valuePerKmOffer.toStringAsFixed(2)}/km (precisa ≥ R\$${minValuePerKm.toStringAsFixed(2)})\nGanho estimado: R\$${estimatedProfit.toStringAsFixed(2)}';
    }

    return TrafficLightResult(light: light, reason: reason, score: score);
  }

  /// Cria RideOffer a partir de notificação
  static RideOffer createRideOfferFromNotification(
    String title,
    String body, {
    String? packageName,
    required Vehicle vehicle,
  }) {
    final app = detectAppFromNotification(
      title,
      body,
      packageName: packageName,
    );
    final data = extractNotificationData(title, body, app);

    final offer = RideOffer(
      id: const Uuid().v4(),
      app: app,
      pickupLocation:
          data['pickup'] as String? ?? 'Local de saída não detectado',
      dropoffLocation:
          data['dropoff'] as String? ?? 'Local de destino não detectado',
      distanceKm: data['distance'] as double?,
      estimatedTimeMinutes: data['time'] as double?,
      offeredValue: data['value'] as double?,
      detectedAt: DateTime.now(),
      trafficLight: TrafficLight.YELLOW,
      trafficLightReason: 'Analisando...',
      profitabilityScore: 0,
    );

    // Calcular semáforo
    final result = calculateTrafficLight(offer, vehicle);

    return RideOffer(
      id: offer.id,
      app: app,
      pickupLocation: offer.pickupLocation,
      dropoffLocation: offer.dropoffLocation,
      distanceKm: offer.distanceKm,
      estimatedTimeMinutes: offer.estimatedTimeMinutes,
      offeredValue: offer.offeredValue,
      detectedAt: offer.detectedAt,
      trafficLight: result.light,
      trafficLightReason: result.reason,
      profitabilityScore: result.score,
    );
  }

  /// Tenta processar notificação e retorna RideOffer se aplicável
  static RideOffer? tryParseNotification(
    String? title,
    String? body, {
    String? packageName,
    required Vehicle vehicle,
  }) {
    if (title == null || body == null) return null;

    // Verificar se é notificação de ride-sharing
    final app = detectAppFromNotification(
      title,
      body,
      packageName: packageName,
    );
    if (app == RideApp.UNKNOWN) return null;

    try {
      return createRideOfferFromNotification(
        title,
        body,
        packageName: packageName,
        vehicle: vehicle,
      );
    } catch (e) {
      print('Erro ao processar notificação: $e');
      return null;
    }
  }
}
