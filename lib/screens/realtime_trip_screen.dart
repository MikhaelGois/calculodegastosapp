import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/vehicle_provider.dart';
import '../providers/history_provider.dart';
import '../services/trip_calculation_service.dart';
import '../models/trip.dart';
import '../widgets/custom_widgets.dart';
import '../utils/format_utils.dart';

class RealTimeTripScreen extends StatefulWidget {
  const RealTimeTripScreen({Key? key}) : super(key: key);

  @override
  State<RealTimeTripScreen> createState() => _RealTimeTripScreenState();
}

class _RealTimeTripScreenState extends State<RealTimeTripScreen> {
  late DateTime _tripStartTime;
  late Timer _timer;
  double _distanceKm = 0.0;
  bool _isTracking = false;
  Trip? _currentTrip;
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _startAddressController = TextEditingController();
  final TextEditingController _endAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tripStartTime = DateTime.now();
  }

  void _startTrip() {
    setState(() {
      _isTracking = true;
      _tripStartTime = DateTime.now();
      _distanceKm = 0.0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {}); // Atualiza a UI a cada segundo
    });
  }

  void _endTrip() {
    _timer.cancel();
    final vehicleProvider = context.read<VehicleProvider>();
    final historyProvider = context.read<HistoryProvider>();

    if (vehicleProvider.selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um veículo')),
      );
      return;
    }

    if (_distanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a distância')),
      );
      return;
    }

    final distance = double.parse(_distanceController.text);
    final vehicle = vehicleProvider.selectedVehicle!;
    final settings = vehicle.operationalSettings;

    // Calcular custos
    final costPerKm = settings.costPerKm;
    final costPerHour = settings.costPerHour;
    final endTime = DateTime.now();

    final trip = Trip(
      id: UniqueKey().toString(),
      vehicleId: vehicle.id,
      startTime: _tripStartTime,
      endTime: endTime,
      distance: distance,
      totalCost: (distance * costPerKm + 
                  endTime.difference(_tripStartTime).inMinutes / 60 * costPerHour) / 2,
      earnings: distance * costPerKm * 0.7 +
          endTime.difference(_tripStartTime).inMinutes / 60 * costPerHour * 0.7,
      startAddress: _startAddressController.text,
      endAddress: _endAddressController.text,
    );

    // Salvar corrida
    historyProvider.addTrip(trip);

    // Mostrar notificação
    final notification = TripNotification(
      id: UniqueKey().toString(),
      tripId: trip.id,
      title: 'Corrida Finalizada',
      message: TripCalculationService.generateTripMessage(trip),
      createdAt: DateTime.now(),
    );

    historyProvider.addNotification(notification);

    setState(() {
      _isTracking = false;
      _distanceController.clear();
      _startAddressController.clear();
      _endAddressController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Corrida salva! Ganho: ${FormatUtils.formatCurrency(trip.earnings)}'),
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(context);
  }

  Duration get _elapsedTime => DateTime.now().difference(_tripStartTime);

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _startAddressController.dispose();
    _endAddressController.dispose();
    if (_isTracking) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isTracking) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cancelar Corrida?'),
              content: const Text(
                'Deseja realmente cancelar essa corrida? Os dados não serão salvos.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Não'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sim', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          if (confirm == true) {
            _timer.cancel();
            return true;
          }
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Corrida em Tempo Real'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de tempo decorrido
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Tempo Decorrido',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _formatDuration(_elapsedTime),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: const Color(0xFF1F77D2),
                              fontFeatureSettings: const 'tnum',
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Formulário de entrada
              if (!_isTracking) ...[
                SectionHeader(
                  title: 'Dados da Corrida',
                  icon: Icons.edit,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _startAddressController,
                  decoration: InputDecoration(
                    labelText: 'Endereço de Saída',
                    hintText: 'Ex: Rua A, 123',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _endAddressController,
                  decoration: InputDecoration(
                    labelText: 'Endereço de Destino',
                    hintText: 'Ex: Rua B, 456',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _distanceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Distância (km)',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.route),
                    suffixText: 'km',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _startTrip,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar Corrida'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Seção de pausa
                const SectionHeader(
                  title: 'Corrida em Progresso',
                  icon: Icons.directions_car,
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Endereço Saída', _startAddressController.text),
                        const SizedBox(height: 12),
                        _buildInfoRow('Endereço Destino', _endAddressController.text),
                        const SizedBox(height: 12),
                        _buildInfoRow('Distância', '${_distanceController.text} km'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _isTracking = false);
                          _timer.cancel();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Pausar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _endTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Finalizar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
