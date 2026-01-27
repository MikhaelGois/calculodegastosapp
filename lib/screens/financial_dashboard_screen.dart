import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_provider.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/transaction_card.dart';
import 'transaction_form_screen.dart';

/// Tela do dashboard financeiro
class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FinancialDashboardScreen> createState() =>
      _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  String _selectedPeriod = 'Hoje';
  final List<String> _periods = ['Hoje', 'Semana', 'Mês', 'Total'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Consumer<FinancialProvider>(
        builder: (context, provider, child) {
          final summary = _getSummary(provider);
          final transactions = _getTransactions(provider);

          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma transação registrada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione suas receitas e despesas',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addTransaction,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Transação'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Seletor de período
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: _periods
                        .map(
                          (period) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  period,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: _selectedPeriod == period,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedPeriod = period;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              // Card de resumo
              SliverToBoxAdapter(
                child: FinancialSummaryCard(
                  summary: summary,
                  period: _selectedPeriod,
                ),
              ),

              // Estatísticas rápidas
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              '📊 Média Diária',
                              _formatCurrency(provider.dailyAverageProfit),
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              '🔄 Recorrentes',
                              '${provider.upcomingRecurring.length}',
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (provider.topExpenses.isNotEmpty)
                        _buildTopExpenseCard(provider.topExpenses.first),
                    ],
                  ),
                ),
              ),

              // Cabeçalho da lista
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transações',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${transactions.length} ${transactions.length == 1 ? 'transação' : 'transações'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              // Lista de transações
              if (transactions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Nenhuma transação neste período',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final transaction = transactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      onTap: () => _viewTransaction(transaction.id),
                      onEdit: () => _editTransaction(transaction.id),
                      onDelete: () =>
                          provider.removeTransaction(transaction.id),
                    );
                  }, childCount: transactions.length),
                ),

              // Espaçamento para o FAB
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTransaction,
        icon: const Icon(Icons.add),
        label: const Text('Nova Transação'),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExpenseCard(MapEntry entry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  entry.key.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💸 Maior Despesa',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.key.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatCurrency(entry.value),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic _getSummary(FinancialProvider provider) {
    switch (_selectedPeriod) {
      case 'Hoje':
        return provider.todaySummary;
      case 'Semana':
        return provider.weekSummary;
      case 'Mês':
        return provider.monthSummary;
      case 'Total':
      default:
        return provider.totalSummary;
    }
  }

  List _getTransactions(FinancialProvider provider) {
    switch (_selectedPeriod) {
      case 'Hoje':
        return provider.todayTransactions;
      case 'Semana':
        return provider.weekTransactions;
      case 'Mês':
        return provider.monthTransactions;
      case 'Total':
      default:
        return provider.transactions;
    }
  }

  void _addTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TransactionFormScreen()),
    );
  }

  void _editTransaction(String transactionId) {
    final provider = Provider.of<FinancialProvider>(context, listen: false);
    final transaction = provider.transactions.firstWhere(
      (t) => t.id == transactionId,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(transaction: transaction),
      ),
    );
  }

  void _viewTransaction(String transactionId) {
    // TODO: Implementar tela de detalhes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detalhes da transação em desenvolvimento')),
    );
  }

  void _showFilterOptions() {
    // TODO: Implementar filtros avançados
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Filtros em desenvolvimento')));
  }

  String _formatCurrency(double amount) {
    return 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
