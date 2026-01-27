import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../widgets/custom_widgets.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormScreen({Key? key, this.vehicle}) : super(key: key);

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _installmentController;
  late TextEditingController _ipvaController;
  late TextEditingController _insuranceController;
  late TextEditingController _oilController;
  late TextEditingController _tireController;
  late TextEditingController _maintenanceController;
  late TextEditingController _fuelPriceController;
  late TextEditingController _tankSizeController;
  late TextEditingController _cityConsumptionController;
  late TextEditingController _highwayConsumptionController;
  late TextEditingController _weeklyKmController;
  late TextEditingController _workDaysController;
  late TextEditingController _workHoursController;
  late TextEditingController _profitController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.vehicle != null) {
      final v = widget.vehicle!;
      _nameController = TextEditingController(text: v.name);
      _typeController = TextEditingController(text: v.type);
      _installmentController = TextEditingController(
        text: v.fixedCosts.monthlyInstallment.toString(),
      );
      _ipvaController = TextEditingController(
        text: v.fixedCosts.annualIPVA.toString(),
      );
      _insuranceController = TextEditingController(
        text: v.fixedCosts.annualInsurance.toString(),
      );
      _oilController = TextEditingController(
        text: v.fixedCosts.oilChangeCost.toString(),
      );
      _tireController = TextEditingController(
        text: v.fixedCosts.tireCost.toString(),
      );
      _maintenanceController = TextEditingController(
        text: v.fixedCosts.maintenanceCost.toString(),
      );
      _fuelPriceController = TextEditingController(
        text: v.variableCosts.fuelPrice.toString(),
      );
      _tankSizeController = TextEditingController(
        text: v.variableCosts.tankSize.toString(),
      );
      _cityConsumptionController = TextEditingController(
        text: v.variableCosts.cityConsumption.toString(),
      );
      _highwayConsumptionController = TextEditingController(
        text: v.variableCosts.highwayConsumption.toString(),
      );
      _weeklyKmController = TextEditingController(
        text: v.operationalSettings.weeklyKmLimit.toString(),
      );
      _workDaysController = TextEditingController(
        text: v.operationalSettings.workDaysPerWeek.toString(),
      );
      _workHoursController = TextEditingController(
        text: v.operationalSettings.workHoursPerDay.toString(),
      );
      _profitController = TextEditingController(
        text: v.operationalSettings.desiredProfit.toString(),
      );
    } else {
      _nameController = TextEditingController();
      _typeController = TextEditingController();
      _installmentController = TextEditingController();
      _ipvaController = TextEditingController();
      _insuranceController = TextEditingController();
      _oilController = TextEditingController();
      _tireController = TextEditingController();
      _maintenanceController = TextEditingController();
      _fuelPriceController = TextEditingController();
      _tankSizeController = TextEditingController();
      _cityConsumptionController = TextEditingController();
      _highwayConsumptionController = TextEditingController();
      _weeklyKmController = TextEditingController();
      _workDaysController = TextEditingController();
      _workHoursController = TextEditingController();
      _profitController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _installmentController.dispose();
    _ipvaController.dispose();
    _insuranceController.dispose();
    _oilController.dispose();
    _tireController.dispose();
    _maintenanceController.dispose();
    _fuelPriceController.dispose();
    _tankSizeController.dispose();
    _cityConsumptionController.dispose();
    _highwayConsumptionController.dispose();
    _weeklyKmController.dispose();
    _workDaysController.dispose();
    _workHoursController.dispose();
    _profitController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    final name = _nameController.text.trim();
    final type = _typeController.text.trim();

    if (name.isEmpty || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final fixedCosts = FixedCosts(
      monthlyInstallment: double.tryParse(_installmentController.text) ?? 0,
      annualIPVA: double.tryParse(_ipvaController.text) ?? 0,
      annualInsurance: double.tryParse(_insuranceController.text) ?? 0,
      oilChangeCost: double.tryParse(_oilController.text) ?? 0,
      tireCost: double.tryParse(_tireController.text) ?? 0,
      maintenanceCost: double.tryParse(_maintenanceController.text) ?? 0,
    );

    final variableCosts = VariableCosts(
      fuelPrice: double.tryParse(_fuelPriceController.text) ?? 0,
      tankSize: double.tryParse(_tankSizeController.text) ?? 0,
      cityConsumption: double.tryParse(_cityConsumptionController.text) ?? 0,
      highwayConsumption:
          double.tryParse(_highwayConsumptionController.text) ?? 0,
    );

    final operationalSettings = OperationalSettings(
      weeklyKmLimit: double.tryParse(_weeklyKmController.text) ?? 2000,
      workDaysPerWeek: int.tryParse(_workDaysController.text) ?? 5,
      workHoursPerDay: int.tryParse(_workHoursController.text) ?? 8,
      desiredProfit: double.tryParse(_profitController.text) ?? 0,
    );

    final vehicle = Vehicle(
      id: widget.vehicle?.id,
      name: name,
      type: type,
      fixedCosts: fixedCosts,
      variableCosts: variableCosts,
      operationalSettings: operationalSettings,
      createdAt: widget.vehicle?.createdAt,
    );

    final provider = context.read<VehicleProvider>();
    if (widget.vehicle != null) {
      provider.updateVehicle(vehicle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veículo atualizado com sucesso')),
      );
    } else {
      provider.addVehicle(vehicle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veículo adicionado com sucesso')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle != null ? 'Editar Veículo' : 'Novo Veículo'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionHeader(title: 'Informações do Veículo', icon: Icons.info),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Nome do Veículo',
              hint: 'Ex: Carro 1',
              onChanged: (_) {},
              initialValue: _nameController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Tipo',
              hint: 'Ex: Sedan, SUV, Utilitário',
              onChanged: (_) {},
              initialValue: _typeController.text,
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Custos Fixos (Mensais)',
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Parcela do Veículo',
              prefix: 'R\$',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _installmentController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'IPVA Anual',
              prefix: 'R\$',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _ipvaController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Seguro Anual',
              prefix: 'R\$',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _insuranceController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Troca de Óleo',
              prefix: 'R\$',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _oilController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Pneu (unitário)',
              prefix: 'R\$',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _tireController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Manutenção/Revisão',
              prefix: 'R\$',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _maintenanceController.text,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Combustível', icon: Icons.local_gas_station),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Preço do Combustível',
              prefix: 'R\$',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _fuelPriceController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Tamanho do Tanque',
              prefix: 'L',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _tankSizeController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Consumo na Cidade',
              prefix: 'km/l',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _cityConsumptionController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Consumo na Rodovia',
              prefix: 'km/l',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _highwayConsumptionController.text,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Operacional', icon: Icons.settings),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Limite de KM Semanal',
              prefix: 'km',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _weeklyKmController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Dias de Trabalho por Semana',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _workDaysController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Horas de Trabalho por Dia',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _workHoursController.text,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Lucro Desejado (Semanal)',
              prefix: 'R\$',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              initialValue: _profitController.text,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Cancelar',
                    isPrimary: false,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(label: 'Salvar', onPressed: _saveVehicle),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
