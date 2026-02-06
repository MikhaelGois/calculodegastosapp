import '../models/trip_model.dart';
import '../models/cost_config_model.dart';

class CalculationService {
  // Calcular custo total para uma corrida específica
  static double calculateTripCost(Trip trip, CostConfig config) {
    // Custo variável (por km)
    double variableCost = trip.distance * config.totalCostPerKm;

    // Custo fixo distribuído pela distância da corrida
    // Considerando que os custos fixos são distribuídos proporcionalmente à distância
    // Isso é uma aproximação - em um cenário real, os custos fixos são diários/mensais
    double fixedCost = config.dailyFixedCost > 0 ? config.dailyFixedCost : 0;

    return variableCost + fixedCost;
  }

  // Calcular lucro de uma corrida
  static double calculateTripProfit(Trip trip, CostConfig config) {
    double totalCost = calculateTripCost(trip, config);
    return trip.value - totalCost;
  }

  // Calcular margem de lucro percentual
  static double calculateProfitMargin(Trip trip, CostConfig config) {
    double profit = calculateTripProfit(trip, config);
    return trip.value > 0 ? (profit / trip.value) * 100 : 0;
  }

  // Determinar se a corrida é recomendável com base em critérios
  static bool isTripRecommended(Trip trip, CostConfig config,
      {double minProfitPercentage = 10.0}) {
    double profitMargin = calculateProfitMargin(trip, config);
    return profitMargin >= minProfitPercentage;
  }

  // Calcular custo por km
  static double calculateCostPerKm(Trip trip, CostConfig config) {
    double totalCost = calculateTripCost(trip, config);
    return trip.distance > 0 ? totalCost / trip.distance : 0;
  }

  // Calcular receita por km
  static double calculateRevenuePerKm(Trip trip) {
    return trip.distance > 0 ? trip.value / trip.distance : 0;
  }

  // Obter recomendação detalhada para uma corrida
  static TripRecommendation getTripRecommendation(
      Trip trip, CostConfig config) {
    double profit = calculateTripProfit(trip, config);
    double profitMargin = calculateProfitMargin(trip, config);
    double costPerKm = calculateCostPerKm(trip, config);
    double revenuePerKm = calculateRevenuePerKm(trip);
    bool isRecommended = isTripRecommended(trip, config);

    return TripRecommendation(
      trip: trip,
      profit: profit,
      profitMargin: profitMargin,
      costPerKm: costPerKm,
      revenuePerKm: revenuePerKm,
      isRecommended: isRecommended,
    );
  }
}

class TripRecommendation {
  final Trip trip;
  final double profit;
  final double profitMargin;
  final double costPerKm;
  final double revenuePerKm;
  final bool isRecommended;

  TripRecommendation({
    required this.trip,
    required this.profit,
    required this.profitMargin,
    required this.costPerKm,
    required this.revenuePerKm,
    required this.isRecommended,
  });
}
