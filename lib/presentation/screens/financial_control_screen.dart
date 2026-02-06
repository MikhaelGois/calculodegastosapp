import 'package:flutter/material.dart';
import 'package:rotalucro/data/models/trip_model.dart';
import 'package:rotalucro/data/models/expense_model.dart';
import 'package:rotalucro/data/storage/local_storage_service.dart';
import 'package:intl/intl.dart';

class FinancialControlScreen extends StatefulWidget {
  const FinancialControlScreen({super.key});

  @override
  State<FinancialControlScreen> createState() => _FinancialControlScreenState();
}

class _FinancialControlScreenState extends State<FinancialControlScreen> {
  List<Trip> _trips = [];
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _trips = await LocalStorageService.loadTrips();
    _expenses = await LocalStorageService.loadExpenses();

    setState(() {
      _isLoading = false;
    });
  }

  double _getTotalTripsValue() {
    return _trips.fold(0, (sum, trip) => sum + trip.value);
  }

  double _getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.value);
  }

  int _getTotalTripsCount() {
    return _trips.length;
  }

  double _getAverageTripValue() {
    if (_trips.isEmpty) return 0;
    return _getTotalTripsValue() / _trips.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumo financeiro
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Resumo Financeiro',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryCard(
                            'Corridas',
                            '${_getTotalTripsCount()}',
                            Colors.blue,
                          ),
                          _buildSummaryCard(
                            'Receita Total',
                            'R\$ ${_getTotalTripsValue().toStringAsFixed(2)}',
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryCard(
                            'Despesas',
                            'R\$ ${_getTotalExpenses().toStringAsFixed(2)}',
                            Colors.red,
                          ),
                          _buildSummaryCard(
                            'Média Corrida',
                            'R\$ ${_getAverageTripValue().toStringAsFixed(2)}',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lista de corridas
              const Text(
                'Últimas Corridas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              if (_trips.isEmpty)
                const Center(
                  child: Text('Nenhuma corrida registrada'),
                )
              else
                ..._trips.reversed.take(5).map((trip) => _buildTripCard(trip)),

              const SizedBox(height: 20),

              // Lista de despesas
              const Text(
                'Últimas Despesas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              if (_expenses.isEmpty)
                const Center(
                  child: Text('Nenhuma despesa registrada'),
                )
              else
                ..._expenses.reversed
                    .take(5)
                    .map((expense) => _buildExpenseCard(expense)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return SizedBox(
      width: 150,
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.local_taxi,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Corrida ${DateFormat('dd/MM/yyyy').format(trip.date)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${trip.distance.toStringAsFixed(1)} km • ${trip.app ?? 'App desconhecido'}',
        ),
        trailing: Text(
          'R\$ ${trip.value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.money_off,
            color: Colors.white,
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${expense.category} • ${DateFormat('dd/MM/yyyy').format(expense.date)}',
        ),
        trailing: Text(
          'R\$ ${expense.value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
