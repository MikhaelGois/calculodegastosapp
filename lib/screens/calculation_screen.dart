import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/custom_widgets.dart';
import '../utils/format_utils.dart';
import 'results_screen.dart';

class CalculationScreen extends StatefulWidget {
  const CalculationScreen({Key? key}) : super(key: key);

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calcular'), elevation: 0),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, _) {
          if (provider.selectedVehicle == null) {
            return const Center(child: Text('Nenhum veículo selecionado'));
          }

          final vehicle = provider.selectedVehicle!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SectionHeader(
                  title: 'Resumo do Veículo',
                  icon: Icons.directions_car,
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vehicle.type,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Custos Fixos Mensais',
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 12),
                ResultCard(
                  title: 'Total de Custos Fixos',
                  value: FormatUtils.formatCurrency(
                    vehicle.fixedCosts.monthlyTotal,
                  ),
                  backgroundColor: Colors.red.shade50,
                  icon: Icons.trending_down,
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Custos Variáveis',
                  icon: Icons.local_gas_station,
                ),
                const SizedBox(height: 12),
                ResultCard(
                  title: 'Preço do Combustível',
                  value: FormatUtils.formatCurrency(
                    vehicle.variableCosts.fuelPrice,
                  ),
                  subtitle:
                      'Consumo médio: ${FormatUtils.formatNumber(vehicle.variableCosts.averageConsumption)} km/l',
                  backgroundColor: Colors.orange.shade50,
                  icon: Icons.local_gas_station,
                ),
                const SizedBox(height: 12),
                ResultCard(
                  title: 'Custo por KM',
                  value: FormatUtils.formatCurrency(
                    vehicle.variableCosts.costPerKm,
                  ),
                  backgroundColor: Colors.orange.shade50,
                  icon: Icons.route,
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Configurações Operacionais',
                  icon: Icons.settings,
                ),
                const SizedBox(height: 12),
                ResultCard(
                  title: 'Limite Semanal',
                  value: FormatUtils.formatKm(
                    vehicle.operationalSettings.weeklyKmLimit,
                  ),
                  backgroundColor: Colors.blue.shade50,
                  icon: Icons.route,
                ),
                const SizedBox(height: 12),
                ResultCard(
                  title: 'Horas Semanais',
                  value: FormatUtils.formatHours(
                    vehicle.operationalSettings.weeklyHours,
                  ),
                  subtitle:
                      '${vehicle.operationalSettings.workDaysPerWeek} dias × ${vehicle.operationalSettings.workHoursPerDay} horas',
                  backgroundColor: Colors.blue.shade50,
                  icon: Icons.access_time,
                ),
                const SizedBox(height: 12),
                ResultCard(
                  title: 'Lucro Desejado',
                  value: FormatUtils.formatCurrency(
                    vehicle.operationalSettings.desiredProfit,
                  ),
                  subtitle: 'Por semana',
                  backgroundColor: Colors.green.shade50,
                  icon: Icons.trending_up,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Calcular Resultados',
                  icon: Icons.calculate,
                  onPressed: () {
                    provider.calculateResults();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ResultsScreen(),
                      ),
                    );
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
