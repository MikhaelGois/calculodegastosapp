import '../models/vehicle.dart';
import '../models/calculation_result.dart';

class CalculationService {
  static CalculationResult calculate(Vehicle vehicle) {
    final fixedCosts = vehicle.fixedCosts;
    final variableCosts = vehicle.variableCosts;
    final settings = vehicle.operationalSettings;

    // Custos diários
    final dailyFixedCost = fixedCosts.monthlyTotal / 30;
    final dailyVariableCost =
        (settings.weeklyKmLimit / 7) * variableCosts.costPerKm;

    final totalDailyCost = dailyFixedCost + dailyVariableCost;

    // Ganho desejado por dia
    final desiredDailyProfit = settings.desiredProfit / 7;

    // Valor por hora
    final valuePerHour =
        (totalDailyCost + desiredDailyProfit) / settings.workHoursPerDay;

    // Valor por km
    final valuePerKm =
        ((totalDailyCost + desiredDailyProfit) / settings.weeklyKmLimit) * 7;

    // Lucro real
    final dailyProfit = desiredDailyProfit;
    final weeklyProfit = desiredDailyProfit * settings.workDaysPerWeek;

    return CalculationResult(
      dailyProfit: dailyProfit,
      weeklyProfit: weeklyProfit,
      valuePerHour: valuePerHour,
      valuePerKm: valuePerKm,
      totalFixedCostPerDay: dailyFixedCost,
      totalVariableCostPerDay: dailyVariableCost,
    );
  }

  static Map<String, double> getDetailedBreakdown(Vehicle vehicle) {
    final fixedCosts = vehicle.fixedCosts;
    final variableCosts = vehicle.variableCosts;
    final settings = vehicle.operationalSettings;

    return {
      'monthlyInstallment': fixedCosts.monthlyInstallment,
      'monthlyIPVA': fixedCosts.annualIPVA / 12,
      'monthlyInsurance': fixedCosts.annualInsurance / 12,
      'monthlyOil': fixedCosts.oilChangeCost / 12,
      'monthlyTire': fixedCosts.tireCost / 12,
      'monthlyMaintenance': fixedCosts.maintenanceCost / 12,
      'totalMonthlyFixed': fixedCosts.monthlyTotal,
      'fuelPrice': variableCosts.fuelPrice,
      'costPerKm': variableCosts.costPerKm,
      'weeklyKmLimit': settings.weeklyKmLimit,
      'desiredProfit': settings.desiredProfit,
    };
  }
}
