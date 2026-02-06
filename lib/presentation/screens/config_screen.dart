import 'package:flutter/material.dart';
import 'package:rotalucro/data/models/cost_config_model.dart';
import 'package:rotalucro/data/storage/local_storage_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late VehicleType _selectedVehicleType;
  late double _vehicleMonthlyPayment;
  late double _vehicleInsurance;
  late InsuranceType _selectedInsuranceType;
  late double _maintenancePerKm;
  late double _fuelPerKm;
  late double _otherFixedCosts;
  late double _otherVariableCostsPerKm;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    CostConfig? config = await LocalStorageService.loadCostConfig();
    if (config != null) {
      setState(() {
        _selectedVehicleType = config.vehicleType;
        _vehicleMonthlyPayment = config.vehicleMonthlyPayment;
        _vehicleInsurance = config.vehicleInsurance;
        _selectedInsuranceType = config.insuranceType;
        _maintenancePerKm = config.maintenancePerKm;
        _fuelPerKm = config.fuelPerKm;
        _otherFixedCosts = config.otherFixedCosts;
        _otherVariableCostsPerKm = config.otherVariableCostsPerKm;
      });
    } else {
      // Valores padrão
      setState(() {
        _selectedVehicleType = VehicleType.ownPaidOff;
        _vehicleMonthlyPayment = 0.0;
        _vehicleInsurance = 0.0;
        _selectedInsuranceType = InsuranceType.monthly;
        _maintenancePerKm = 0.10;
        _fuelPerKm = 0.80;
        _otherFixedCosts = 300.0;
        _otherVariableCostsPerKm = 0.05;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      CostConfig config = CostConfig(
        vehicleType: _selectedVehicleType,
        vehicleMonthlyPayment: _vehicleMonthlyPayment,
        vehicleInsurance: _vehicleInsurance,
        insuranceType: _selectedInsuranceType,
        maintenancePerKm: _maintenancePerKm,
        fuelPerKm: _fuelPerKm,
        otherFixedCosts: _otherFixedCosts,
        otherVariableCostsPerKm: _otherVariableCostsPerKm,
      );

      await LocalStorageService.saveCostConfig(config);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Custos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tipo de veículo
              const Text(
                'Tipo de Veículo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: VehicleType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: _selectedVehicleType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedVehicleType =
                            selected ? type : _selectedVehicleType;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Pagamento do veículo (se financiado)
              if (_selectedVehicleType == VehicleType.ownFinanced)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Parcela do Veículo (R\$)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    TextFormField(
                      initialValue: _vehicleMonthlyPayment.toStringAsFixed(2),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe a parcela';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _vehicleMonthlyPayment =
                            double.tryParse(value ?? '0') ?? 0.0;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Ex: 800.00',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Seguro
              const Text(
                'Seguro',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _vehicleInsurance.toStringAsFixed(2),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o valor do seguro';
                  }
                  return null;
                },
                onSaved: (value) {
                  _vehicleInsurance = double.tryParse(value ?? '0') ?? 0.0;
                },
                decoration: const InputDecoration(
                  hintText: 'Valor do seguro',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: InsuranceType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: _selectedInsuranceType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedInsuranceType =
                            selected ? type : _selectedInsuranceType;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Custo de manutenção por km
              const Text(
                'Manutenção por KM (R\$)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              TextFormField(
                initialValue: _maintenancePerKm.toStringAsFixed(2),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o custo de manutenção por km';
                  }
                  return null;
                },
                onSaved: (value) {
                  _maintenancePerKm = double.tryParse(value ?? '0') ?? 0.0;
                },
                decoration: const InputDecoration(
                  hintText: 'Ex: 0.10',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Custo de combustível por km
              const Text(
                'Combustível por KM (R\$)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              TextFormField(
                initialValue: _fuelPerKm.toStringAsFixed(2),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o custo de combustível por km';
                  }
                  return null;
                },
                onSaved: (value) {
                  _fuelPerKm = double.tryParse(value ?? '0') ?? 0.0;
                },
                decoration: const InputDecoration(
                  hintText: 'Ex: 0.80',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Outros custos fixos mensais
              const Text(
                'Outros Custos Fixos Mensais (R\$)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              TextFormField(
                initialValue: _otherFixedCosts.toStringAsFixed(2),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe os outros custos fixos';
                  }
                  return null;
                },
                onSaved: (value) {
                  _otherFixedCosts = double.tryParse(value ?? '0') ?? 0.0;
                },
                decoration: const InputDecoration(
                  hintText: 'Ex: 300.00',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Outros custos variáveis por km
              const Text(
                'Outros Custos Variáveis por KM (R\$)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              TextFormField(
                initialValue: _otherVariableCostsPerKm.toStringAsFixed(2),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe os outros custos variáveis por km';
                  }
                  return null;
                },
                onSaved: (value) {
                  _otherVariableCostsPerKm =
                      double.tryParse(value ?? '0') ?? 0.0;
                },
                decoration: const InputDecoration(
                  hintText: 'Ex: 0.05',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Botão para salvar
              ElevatedButton(
                onPressed: _saveConfig,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Salvar Configurações',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
