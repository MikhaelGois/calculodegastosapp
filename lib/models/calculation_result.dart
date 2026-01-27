class CalculationResult {
  final double dailyProfit;
  final double weeklyProfit;
  final double valuePerHour;
  final double valuePerKm;
  final double totalFixedCostPerDay;
  final double totalVariableCostPerDay;
  final DateTime calculatedAt;

  CalculationResult({
    required this.dailyProfit,
    required this.weeklyProfit,
    required this.valuePerHour,
    required this.valuePerKm,
    required this.totalFixedCostPerDay,
    required this.totalVariableCostPerDay,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'dailyProfit': dailyProfit,
      'weeklyProfit': weeklyProfit,
      'valuePerHour': valuePerHour,
      'valuePerKm': valuePerKm,
      'totalFixedCostPerDay': totalFixedCostPerDay,
      'totalVariableCostPerDay': totalVariableCostPerDay,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory CalculationResult.fromMap(Map<String, dynamic> map) {
    return CalculationResult(
      dailyProfit: (map['dailyProfit'] ?? 0).toDouble(),
      weeklyProfit: (map['weeklyProfit'] ?? 0).toDouble(),
      valuePerHour: (map['valuePerHour'] ?? 0).toDouble(),
      valuePerKm: (map['valuePerKm'] ?? 0).toDouble(),
      totalFixedCostPerDay: (map['totalFixedCostPerDay'] ?? 0).toDouble(),
      totalVariableCostPerDay: (map['totalVariableCostPerDay'] ?? 0).toDouble(),
      calculatedAt: DateTime.parse(map['calculatedAt']),
    );
  }
}
