import 'package:flutter/material.dart';
import 'package:rotalucro/data/models/trip_model.dart';
import 'package:rotalucro/data/models/cost_config_model.dart';
import 'package:rotalucro/data/services/calculation_service.dart';
import 'package:rotalucro/data/storage/local_storage_service.dart';
import 'package:uuid/uuid.dart';

class ManualCalcScreen extends StatefulWidget {
  const ManualCalcScreen({super.key});

  @override
  State<ManualCalcScreen> createState() => _ManualCalcScreenState();
}

class _ManualCalcScreenState extends State<ManualCalcScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  CostConfig? _config;
  TripRecommendation? _recommendation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    _config = await LocalStorageService.loadCostConfig();
  }

  Future<void> _calculate() async {
    if (_formKey.currentState!.validate() && _config != null) {
      setState(() {
        _isLoading = true;
      });

      double distance = double.parse(_distanceController.text);
      double value = double.parse(_valueController.text);

      Trip trip = Trip(
        id: const Uuid().v4(),
        distance: distance,
        value: value,
        date: DateTime.now(),
      );

      TripRecommendation recommendation =
          CalculationService.getTripRecommendation(trip, _config!);

      setState(() {
        _recommendation = recommendation;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_recommendation != null) {
      List<Trip> trips = await LocalStorageService.loadTrips();
      trips.add(_recommendation!.trip);
      await LocalStorageService.saveTrips(trips);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corrida salva com sucesso!')),
      );

      // Limpar formulário
      _distanceController.clear();
      _valueController.clear();
      setState(() {
        _recommendation = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo Manual'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Formulário de entrada
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Insira os dados da corrida',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Distância
                      TextFormField(
                        controller: _distanceController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe a distância';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Distância inválida';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Distância (km)',
                          hintText: 'Ex: 5.5',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Valor
                      TextFormField(
                        controller: _valueController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o valor';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Valor (R\$)',
                          hintText: 'Ex: 25.00',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botão de calcular
                      ElevatedButton(
                        onPressed: _isLoading ? null : _calculate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Calcular Rentabilidade',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Resultado
              if (_recommendation != null) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resultado da Análise',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Recomendação
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _recommendation!.isRecommended
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _recommendation!.isRecommended
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _recommendation!.isRecommended
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _recommendation!.isRecommended
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _recommendation!.isRecommended
                                    ? 'BOA CORRIDA!'
                                    : 'NÃO RECOMENDADA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _recommendation!.isRecommended
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Detalhes
                        _buildDetailRow(
                            'Lucro Estimado:',
                            'R\$ ${_recommendation!.profit.toStringAsFixed(2)}',
                            _recommendation!.profit >= 0
                                ? Colors.green
                                : Colors.red),

                        _buildDetailRow(
                            'Margem de Lucro:',
                            '${_recommendation!.profitMargin.toStringAsFixed(2)}%',
                            _recommendation!.profitMargin >= 0
                                ? Colors.green
                                : Colors.red),

                        _buildDetailRow(
                            'Custo por KM:',
                            'R\$ ${_recommendation!.costPerKm.toStringAsFixed(2)}',
                            Colors.black),

                        _buildDetailRow(
                            'Receita por KM:',
                            'R\$ ${_recommendation!.revenuePerKm.toStringAsFixed(2)}',
                            Colors.black),

                        const SizedBox(height: 20),

                        // Botão para salvar
                        ElevatedButton(
                          onPressed: _saveTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Salvar Corrida'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_config == null) ...[
                const SizedBox(height: 20),
                Card(
                  color: Colors.yellow.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Atenção!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Você ainda não configurou seus custos. Acesse a aba "Config" para definir seus custos de operação e obter cálculos mais precisos.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}
