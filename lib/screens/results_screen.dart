import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/custom_widgets.dart';
import '../utils/format_utils.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumo'),
            Tab(text: 'Detalhes'),
          ],
        ),
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, _) {
          final result = provider.lastCalculation;

          if (result == null) {
            return const Center(child: Text('Nenhum cálculo realizado ainda'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(context, provider, result),
              _buildDetailsTab(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryTab(
    BuildContext context,
    VehicleProvider provider,
    dynamic result,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Resultados Principais',
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 12),
          ResultCard(
            title: 'Ganho Diário',
            value: FormatUtils.formatCurrency(result.dailyProfit),
            subtitle: 'Por dia útil',
            backgroundColor: Colors.green.shade50,
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 12),
          ResultCard(
            title: 'Ganho Semanal',
            value: FormatUtils.formatCurrency(result.weeklyProfit),
            subtitle: 'Total da semana',
            backgroundColor: Colors.green.shade50,
            icon: Icons.calendar_view_week,
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Valores Por Unidade', icon: Icons.pricing),
          const SizedBox(height: 12),
          ResultCard(
            title: 'Valor por Hora',
            value: FormatUtils.formatCurrency(result.valuePerHour),
            backgroundColor: Colors.blue.shade50,
            icon: Icons.access_time,
          ),
          const SizedBox(height: 12),
          ResultCard(
            title: 'Valor por KM',
            value: FormatUtils.formatCurrency(result.valuePerKm),
            backgroundColor: Colors.blue.shade50,
            icon: Icons.route,
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Custos Diários', icon: Icons.attach_money),
          const SizedBox(height: 12),
          ResultCard(
            title: 'Custos Fixos',
            value: FormatUtils.formatCurrency(result.totalFixedCostPerDay),
            backgroundColor: Colors.red.shade50,
            icon: Icons.home,
          ),
          const SizedBox(height: 12),
          ResultCard(
            title: 'Custos Variáveis',
            value: FormatUtils.formatCurrency(result.totalVariableCostPerDay),
            backgroundColor: Colors.orange.shade50,
            icon: Icons.local_gas_station,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, VehicleProvider provider) {
    final breakdown = provider.getDetailedBreakdown();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Detalhamento de Custos',
            icon: Icons.assessment,
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
                children: breakdown.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getLabel(entry.key),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          FormatUtils.formatCurrency(entry.value),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getLabel(String key) {
    const labels = {
      'monthlyInstallment': 'Parcela Mensal',
      'monthlyIPVA': 'IPVA Mensal',
      'monthlyInsurance': 'Seguro Mensal',
      'monthlyOil': 'Óleo Mensal',
      'monthlyTire': 'Pneu Mensal',
      'monthlyMaintenance': 'Manutenção Mensal',
      'totalMonthlyFixed': 'Total Mensal Fixo',
      'fuelPrice': 'Preço Combustível',
      'costPerKm': 'Custo por KM',
      'weeklyKmLimit': 'KM Semanal',
      'desiredProfit': 'Lucro Desejado',
    };
    return labels[key] ?? key;
  }
}
