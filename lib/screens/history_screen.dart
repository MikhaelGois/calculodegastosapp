import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/trip.dart';
import '../widgets/custom_widgets.dart';
import '../utils/format_utils.dart';
import '../services/maps_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HistoryProvider>().loadTrips();
      context.read<HistoryProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Corridas'),
        elevation: 0,
      ),
      body: Consumer2<HistoryProvider, VehicleProvider>(
        builder: (context, historyProvider, vehicleProvider, _) {
          final selectedVehicle = vehicleProvider.selectedVehicle;
          
          if (selectedVehicle == null) {
            return const Center(
              child: Text('Selecione um veículo'),
            );
          }

          final trips = historyProvider.getTripsByVehicle(selectedVehicle.id);
          final stats = historyProvider.getStatistics(selectedVehicle.id);

          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma corrida registrada',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Suas corridas aparecerão aqui',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Estatísticas',
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid(context, stats),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Corridas Recentes',
                      icon: Icons.directions_car,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  return _buildTripCard(context, trips[index]);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ResultCard(
          title: 'Total de Corridas',
          value: (stats['totalTrips'] ?? 0).toString(),
          backgroundColor: Colors.blue.shade50,
          icon: Icons.directions_car,
        ),
        ResultCard(
          title: 'Distância Total',
          value:
              '${(stats['totalDistance'] ?? 0).toStringAsFixed(1)} km',
          backgroundColor: Colors.green.shade50,
          icon: Icons.route,
        ),
        ResultCard(
          title: 'Ganhos Totais',
          value: FormatUtils.formatCurrency(stats['totalEarnings'] ?? 0),
          backgroundColor: Colors.emerald.shade50,
          icon: Icons.monetization_on,
        ),
        ResultCard(
          title: 'Avaliação Média',
          value: '${(stats['avgRating'] ?? 0).toStringAsFixed(1)} ⭐',
          backgroundColor: Colors.amber.shade50,
          icon: Icons.star,
        ),
      ],
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final duration = trip.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.startAddress ?? 'Saída',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$hours h ${minutes} min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                FormatUtils.formatCurrency(trip.totalCost),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Distância', '${trip.distance.toStringAsFixed(1)} km'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Velocidade Média',
                      '${trip.avgSpeed.toStringAsFixed(1)} km/h'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Valor/km',
                    FormatUtils.formatCurrency(trip.valuePerKm),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Valor/hora',
                    FormatUtils.formatCurrency(trip.valuePerHour),
                  ),
                  if (trip.passengerRating != null) ...[
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${trip.passengerRating!.stars.toStringAsFixed(1)} - ${trip.passengerRating!.comment ?? 'Sem comentário'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (trip.startAddress != null || trip.endAddress != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (trip.startAddress != null)
                          ElevatedButton.icon(
                            onPressed: () =>
                                MapsService.openMapsWithAddress(trip.startAddress!),
                            icon: const Icon(Icons.location_on, size: 18),
                            label: const Text('Saída'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        if (trip.endAddress != null)
                          ElevatedButton.icon(
                            onPressed: () =>
                                MapsService.openMapsWithAddress(trip.endAddress!),
                            icon: const Icon(Icons.location_on, size: 18),
                            label: const Text('Destino'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
