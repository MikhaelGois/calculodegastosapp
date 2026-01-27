import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../widgets/custom_widgets.dart';
import '../utils/format_utils.dart';
import 'vehicle_form_screen.dart';
import 'calculation_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VehicleProvider>().loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de Gastos'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddVehicleDialog(context),
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.vehicles.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Meus Veículos',
                      icon: Icons.directions_car,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = provider.vehicles[index];
                          final isSelected =
                              provider.selectedVehicle?.id == vehicle.id;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildVehicleCard(
                              context,
                              vehicle,
                              isSelected,
                              provider,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.selectedVehicle != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Ações Rápidas', icon: Icons.bolt),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: 'Calcular',
                              icon: Icons.calculate,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CalculationScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              label: 'Editar',
                              icon: Icons.edit,
                              isPrimary: false,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => VehicleFormScreen(
                                      vehicle: provider.selectedVehicle,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (provider.lastCalculation != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'Último Resultado',
                              icon: Icons.assessment,
                            ),
                            const SizedBox(height: 12),
                            ResultCard(
                              title: 'Ganho por Dia',
                              value: FormatUtils.formatCurrency(
                                provider.lastCalculation!.dailyProfit,
                              ),
                              backgroundColor: Colors.green.shade50,
                              icon: Icons.trending_up,
                            ),
                            const SizedBox(height: 12),
                            ResultCard(
                              title: 'Ganho por Hora',
                              value: FormatUtils.formatCurrency(
                                provider.lastCalculation!.valuePerHour,
                              ),
                              backgroundColor: Colors.blue.shade50,
                              icon: Icons.access_time,
                            ),
                            const SizedBox(height: 12),
                            ResultCard(
                              title: 'Ganho por km',
                              value: FormatUtils.formatCurrency(
                                provider.lastCalculation!.valuePerKm,
                              ),
                              backgroundColor: Colors.orange.shade50,
                              icon: Icons.directions,
                            ),
                            const SizedBox(height: 12),
                            CustomButton(
                              label: 'Ver Detalhes',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ResultsScreen(),
                                  ),
                                );
                              },
                              width: double.infinity,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nenhum veículo cadastrado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Clique no botão + para adicionar um veículo',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Adicionar Veículo',
            icon: Icons.add,
            onPressed: () => _showAddVehicleDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    Vehicle vehicle,
    bool isSelected,
    VehicleProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        provider.selectVehicle(vehicle);
      },
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    vehicle.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.type,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isSelected)
                    Chip(
                      label: const Text('Selecionado'),
                      backgroundColor: Theme.of(context).primaryColor,
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  VehicleFormScreen(vehicle: vehicle),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Deletar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        onTap: () {
                          _showDeleteConfirmation(context, vehicle, provider);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const VehicleFormScreen()));
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Vehicle vehicle,
    VehicleProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Veículo?'),
        content: Text(
          'Deseja realmente deletar "${vehicle.name}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteVehicle(vehicle.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veículo deletado com sucesso')),
              );
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
