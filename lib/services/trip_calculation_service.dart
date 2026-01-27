import '../models/trip.dart';

class TripCalculationService {
  /// Calcula trip em tempo real com tempo e distância
  static Trip calculateTrip({
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    required double distanceKm,
    required double costPerKm,
    required double costPerHour,
    String? startAddress,
    String? endAddress,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
  }) {
    final duration = endTime.difference(startTime);
    final durationHours = duration.inMinutes / 60;

    // Cálculo de custo com ambas variáveis
    final costByDistance = distanceKm * costPerKm;
    final costByTime = durationHours * costPerHour;
    final totalCost = (costByDistance + costByTime) / 2; // Média dos dois

    return Trip(
      vehicleId: vehicleId,
      startTime: startTime,
      endTime: endTime,
      distance: distanceKm,
      totalCost: totalCost,
      earnings: totalCost, // Você pode adicionar margem aqui
      startAddress: startAddress,
      endAddress: endAddress,
      startLatitude: startLat,
      startLongitude: startLng,
      endLatitude: endLat,
      endLongitude: endLng,
    );
  }

  /// Gera mensagem de notificação da corrida
  static String generateTripMessage(Trip trip) {
    final duration = trip.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '''
Corrida Finalizada
━━━━━━━━━━━━━━━━
Distância: ${trip.distance.toStringAsFixed(1)} km
Tempo: $hours h ${minutes} min
Velocidade Média: ${trip.avgSpeed.toStringAsFixed(1)} km/h

💰 Valores:
  • Valor/km: R\$ ${trip.valuePerKm.toStringAsFixed(2)}
  • Valor/hora: R\$ ${trip.valuePerHour.toStringAsFixed(2)}
  • Total: R\$ ${trip.totalCost.toStringAsFixed(2)}

📍 ${trip.startAddress ?? 'Saída'}
${trip.endAddress != null ? '↓' : ''}
${trip.endAddress != null ? '📍 ${trip.endAddress}' : ''}
    ''';
  }

  /// Avalia corrida com feedback do passageiro
  static Trip addRating(Trip trip, {required double stars, String? comment}) {
    final rating = PassengerRating(stars: stars, comment: comment);
    return Trip(
      id: trip.id,
      vehicleId: trip.vehicleId,
      startTime: trip.startTime,
      endTime: trip.endTime,
      distance: trip.distance,
      totalCost: trip.totalCost,
      earnings: trip.earnings,
      startAddress: trip.startAddress,
      endAddress: trip.endAddress,
      startLatitude: trip.startLatitude,
      startLongitude: trip.startLongitude,
      endLatitude: trip.endLatitude,
      endLongitude: trip.endLongitude,
      passengerRating: rating,
      notes: trip.notes,
    );
  }

  /// Valida se os dados de trip estão corretos
  static bool validateTrip(Trip trip) {
    if (trip.distance <= 0) return false;
    if (trip.totalCost < 0) return false;
    if (trip.duration.inMinutes <= 0) return false;
    return true;
  }
}
