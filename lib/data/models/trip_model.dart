class Trip {
  final String id;
  final double distance; // em quilômetros
  final double value; // em reais
  final DateTime date;
  final String? app; // Uber, 99, Indriver, etc.

  Trip({
    required this.id,
    required this.distance,
    required this.value,
    required this.date,
    this.app,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distance': distance,
      'value': value,
      'date': date.toIso8601String(),
      'app': app,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      app: json['app'],
    );
  }

  // Calcular receita por km
  double get revenuePerKm => distance > 0 ? value / distance : 0;

  // Calcular lucro considerando custos (será calculado pelo serviço)
  double calculateProfit(double totalCost) {
    return value - totalCost;
  }

  // Calcular margem de lucro percentual
  double get profitMargin =>
      value > 0 ? ((value - (value - value)) / value) * 100 : 0;
}
