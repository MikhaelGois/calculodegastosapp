enum VehicleType { ownPaidOff, ownFinanced, rented }

enum InsuranceType { monthly, annual }

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.ownPaidOff:
        return 'Próprio Quitado';
      case VehicleType.ownFinanced:
        return 'Próprio Financiado';
      case VehicleType.rented:
        return 'Alugado';
    }
  }
}

extension InsuranceTypeExtension on InsuranceType {
  String get displayName {
    switch (this) {
      case InsuranceType.monthly:
        return 'Mensal';
      case InsuranceType.annual:
        return 'Anual';
    }
  }
}

class CostConfig {
  final VehicleType vehicleType;
  final double vehicleMonthlyPayment; // Parcela do carro (se financiado)
  final double vehicleInsurance; // Valor do seguro
  final InsuranceType insuranceType; // Mensal ou anual
  final double maintenancePerKm; // Manutenção por km
  final double fuelPerKm; // Custo de combustível por km
  final double otherFixedCosts; // Outros custos fixos mensais
  final double otherVariableCostsPerKm; // Outros custos variáveis por km

  CostConfig({
    required this.vehicleType,
    this.vehicleMonthlyPayment = 0.0,
    required this.vehicleInsurance,
    required this.insuranceType,
    required this.maintenancePerKm,
    required this.fuelPerKm,
    required this.otherFixedCosts,
    required this.otherVariableCostsPerKm,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType.toString(),
      'vehicleMonthlyPayment': vehicleMonthlyPayment,
      'vehicleInsurance': vehicleInsurance,
      'insuranceType': insuranceType.toString(),
      'maintenancePerKm': maintenancePerKm,
      'fuelPerKm': fuelPerKm,
      'otherFixedCosts': otherFixedCosts,
      'otherVariableCostsPerKm': otherVariableCostsPerKm,
    };
  }

  factory CostConfig.fromJson(Map<String, dynamic> json) {
    return CostConfig(
      vehicleType: _parseVehicleType(json['vehicleType']),
      vehicleMonthlyPayment:
          (json['vehicleMonthlyPayment'] as num?)?.toDouble() ?? 0.0,
      vehicleInsurance: (json['vehicleInsurance'] as num?)?.toDouble() ?? 0.0,
      insuranceType: _parseInsuranceType(json['insuranceType']),
      maintenancePerKm: (json['maintenancePerKm'] as num?)?.toDouble() ?? 0.0,
      fuelPerKm: (json['fuelPerKm'] as num?)?.toDouble() ?? 0.0,
      otherFixedCosts: (json['otherFixedCosts'] as num?)?.toDouble() ?? 0.0,
      otherVariableCostsPerKm:
          (json['otherVariableCostsPerKm'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static VehicleType _parseVehicleType(String? value) {
    if (value == null) return VehicleType.ownPaidOff;

    switch (value) {
      case 'VehicleType.ownPaidOff':
        return VehicleType.ownPaidOff;
      case 'VehicleType.ownFinanced':
        return VehicleType.ownFinanced;
      case 'VehicleType.rented':
        return VehicleType.rented;
      default:
        return VehicleType.ownPaidOff;
    }
  }

  static InsuranceType _parseInsuranceType(String? value) {
    if (value == null) return InsuranceType.monthly;

    switch (value) {
      case 'InsuranceType.monthly':
        return InsuranceType.monthly;
      case 'InsuranceType.annual':
        return InsuranceType.annual;
      default:
        return InsuranceType.monthly;
    }
  }

  // Calcular custo fixo diário (para distribuir nos kms rodados do dia)
  double get dailyFixedCost {
    // Assumindo 30 dias no mês
    double monthlyFixedCost =
        vehicleMonthlyPayment + _getMonthlyInsuranceCost() + otherFixedCosts;
    return monthlyFixedCost / 30;
  }

  double _getMonthlyInsuranceCost() {
    if (insuranceType == InsuranceType.annual) {
      return vehicleInsurance / 12; // Converter anual para mensal
    } else {
      return vehicleInsurance; // Já é mensal
    }
  }

  // Calcular custo total por km
  double get totalCostPerKm {
    return fuelPerKm + maintenancePerKm + otherVariableCostsPerKm;
  }
}
