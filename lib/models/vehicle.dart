import 'package:uuid/uuid.dart';

class Vehicle {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;
  final FixedCosts fixedCosts;
  final VariableCosts variableCosts;
  final OperationalSettings operationalSettings;

  Vehicle({
    String? id,
    required this.name,
    required this.type,
    DateTime? createdAt,
    required this.fixedCosts,
    required this.variableCosts,
    required this.operationalSettings,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Vehicle copyWith({
    String? name,
    String? type,
    FixedCosts? fixedCosts,
    VariableCosts? variableCosts,
    OperationalSettings? operationalSettings,
  }) {
    return Vehicle(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt,
      fixedCosts: fixedCosts ?? this.fixedCosts,
      variableCosts: variableCosts ?? this.variableCosts,
      operationalSettings: operationalSettings ?? this.operationalSettings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'fixedCosts': fixedCosts.toMap(),
      'variableCosts': variableCosts.toMap(),
      'operationalSettings': operationalSettings.toMap(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      createdAt: DateTime.parse(map['createdAt']),
      fixedCosts: FixedCosts.fromMap(map['fixedCosts']),
      variableCosts: VariableCosts.fromMap(map['variableCosts']),
      operationalSettings: OperationalSettings.fromMap(
        map['operationalSettings'],
      ),
    );
  }
}

class FixedCosts {
  final double monthlyInstallment;
  final double annualIPVA;
  final double annualInsurance;
  final double oilChangeCost;
  final double tireCost;
  final double maintenanceCost;

  FixedCosts({
    this.monthlyInstallment = 0,
    this.annualIPVA = 0,
    this.annualInsurance = 0,
    this.oilChangeCost = 0,
    this.tireCost = 0,
    this.maintenanceCost = 0,
  });

  double get monthlyTotal =>
      (monthlyInstallment +
      (annualIPVA / 12) +
      (annualInsurance / 12) +
      (oilChangeCost / 12) +
      (tireCost / 12) +
      (maintenanceCost / 12));

  FixedCosts copyWith({
    double? monthlyInstallment,
    double? annualIPVA,
    double? annualInsurance,
    double? oilChangeCost,
    double? tireCost,
    double? maintenanceCost,
  }) {
    return FixedCosts(
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
      annualIPVA: annualIPVA ?? this.annualIPVA,
      annualInsurance: annualInsurance ?? this.annualInsurance,
      oilChangeCost: oilChangeCost ?? this.oilChangeCost,
      tireCost: tireCost ?? this.tireCost,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthlyInstallment': monthlyInstallment,
      'annualIPVA': annualIPVA,
      'annualInsurance': annualInsurance,
      'oilChangeCost': oilChangeCost,
      'tireCost': tireCost,
      'maintenanceCost': maintenanceCost,
    };
  }

  factory FixedCosts.fromMap(Map<String, dynamic> map) {
    return FixedCosts(
      monthlyInstallment: (map['monthlyInstallment'] ?? 0).toDouble(),
      annualIPVA: (map['annualIPVA'] ?? 0).toDouble(),
      annualInsurance: (map['annualInsurance'] ?? 0).toDouble(),
      oilChangeCost: (map['oilChangeCost'] ?? 0).toDouble(),
      tireCost: (map['tireCost'] ?? 0).toDouble(),
      maintenanceCost: (map['maintenanceCost'] ?? 0).toDouble(),
    );
  }
}

class VariableCosts {
  final double fuelPrice;
  final double tankSize;
  final double cityConsumption;
  final double highwayConsumption;

  VariableCosts({
    this.fuelPrice = 0,
    this.tankSize = 0,
    this.cityConsumption = 0,
    this.highwayConsumption = 0,
  });

  double get averageConsumption => (cityConsumption + highwayConsumption) / 2;

  double get costPerKm => fuelPrice / averageConsumption;

  VariableCosts copyWith({
    double? fuelPrice,
    double? tankSize,
    double? cityConsumption,
    double? highwayConsumption,
  }) {
    return VariableCosts(
      fuelPrice: fuelPrice ?? this.fuelPrice,
      tankSize: tankSize ?? this.tankSize,
      cityConsumption: cityConsumption ?? this.cityConsumption,
      highwayConsumption: highwayConsumption ?? this.highwayConsumption,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fuelPrice': fuelPrice,
      'tankSize': tankSize,
      'cityConsumption': cityConsumption,
      'highwayConsumption': highwayConsumption,
    };
  }

  factory VariableCosts.fromMap(Map<String, dynamic> map) {
    return VariableCosts(
      fuelPrice: (map['fuelPrice'] ?? 0).toDouble(),
      tankSize: (map['tankSize'] ?? 0).toDouble(),
      cityConsumption: (map['cityConsumption'] ?? 0).toDouble(),
      highwayConsumption: (map['highwayConsumption'] ?? 0).toDouble(),
    );
  }
}

class OperationalSettings {
  final double weeklyKmLimit;
  final int workDaysPerWeek;
  final int workHoursPerDay;
  final double desiredProfit;

  OperationalSettings({
    this.weeklyKmLimit = 2000,
    this.workDaysPerWeek = 5,
    this.workHoursPerDay = 8,
    this.desiredProfit = 0,
  });

  double get weeklyHours => workDaysPerWeek * workHoursPerDay.toDouble();

  OperationalSettings copyWith({
    double? weeklyKmLimit,
    int? workDaysPerWeek,
    int? workHoursPerDay,
    double? desiredProfit,
  }) {
    return OperationalSettings(
      weeklyKmLimit: weeklyKmLimit ?? this.weeklyKmLimit,
      workDaysPerWeek: workDaysPerWeek ?? this.workDaysPerWeek,
      workHoursPerDay: workHoursPerDay ?? this.workHoursPerDay,
      desiredProfit: desiredProfit ?? this.desiredProfit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weeklyKmLimit': weeklyKmLimit,
      'workDaysPerWeek': workDaysPerWeek,
      'workHoursPerDay': workHoursPerDay,
      'desiredProfit': desiredProfit,
    };
  }

  factory OperationalSettings.fromMap(Map<String, dynamic> map) {
    return OperationalSettings(
      weeklyKmLimit: (map['weeklyKmLimit'] ?? 2000).toDouble(),
      workDaysPerWeek: map['workDaysPerWeek'] ?? 5,
      workHoursPerDay: map['workHoursPerDay'] ?? 8,
      desiredProfit: (map['desiredProfit'] ?? 0).toDouble(),
    );
  }
}
