import 'package:flutter/foundation.dart';
import '../models/financial_transaction.dart';
import '../services/financial_service.dart';

/// Provider para gerenciar transações financeiras
class FinancialProvider extends ChangeNotifier {
  final List<FinancialTransaction> _transactions = [];
  DateTime _selectedDate = DateTime.now();
  TransactionType _filterType = TransactionType.INCOME;

  List<FinancialTransaction> get transactions =>
      List.unmodifiable(_transactions);
  DateTime get selectedDate => _selectedDate;
  TransactionType get filterType => _filterType;

  /// Adiciona nova transação
  void addTransaction(FinancialTransaction transaction) {
    _transactions.add(transaction);
    _sortTransactions();
    notifyListeners();
  }

  /// Remove transação
  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Atualiza transação
  void updateTransaction(FinancialTransaction transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _sortTransactions();
      notifyListeners();
    }
  }

  /// Ordena transações por data (mais recente primeiro)
  void _sortTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Define data selecionada para filtros
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Define tipo de filtro
  void setFilterType(TransactionType type) {
    _filterType = type;
    notifyListeners();
  }

  /// Retorna transações filtradas por tipo
  List<FinancialTransaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  /// Retorna transações de hoje
  List<FinancialTransaction> get todayTransactions {
    return FinancialService.getTodayTransactions(_transactions);
  }

  /// Retorna transações desta semana
  List<FinancialTransaction> get weekTransactions {
    return FinancialService.getWeekTransactions(_transactions);
  }

  /// Retorna transações deste mês
  List<FinancialTransaction> get monthTransactions {
    return FinancialService.getMonthTransactions(_transactions);
  }

  /// Resumo financeiro de hoje
  FinancialSummary get todaySummary {
    return FinancialService.calculateSummary(transactions: todayTransactions);
  }

  /// Resumo financeiro desta semana
  FinancialSummary get weekSummary {
    return FinancialService.calculateSummary(transactions: weekTransactions);
  }

  /// Resumo financeiro deste mês
  FinancialSummary get monthSummary {
    return FinancialService.calculateSummary(transactions: monthTransactions);
  }

  /// Resumo financeiro total
  FinancialSummary get totalSummary {
    return FinancialService.calculateSummary(transactions: _transactions);
  }

  /// Resumo financeiro customizado
  FinancialSummary getCustomSummary({DateTime? startDate, DateTime? endDate}) {
    return FinancialService.calculateSummary(
      transactions: _transactions,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Top despesas
  List<MapEntry<ExpenseCategory, double>> get topExpenses {
    return FinancialService.getTopExpenses(_transactions);
  }

  /// Despesas recorrentes próximas
  List<FinancialTransaction> get upcomingRecurring {
    return FinancialService.getUpcomingRecurring(_transactions);
  }

  /// Média diária de lucro (últimos 30 dias)
  double get dailyAverageProfit {
    return FinancialService.calculateDailyAverageProfit(_transactions, 30);
  }

  /// Previsão de despesas do próximo mês
  double get nextMonthExpensesPrediction {
    return FinancialService.predictNextMonthExpenses(_transactions);
  }

  /// Limpa todas as transações
  void clearAllTransactions() {
    _transactions.clear();
    notifyListeners();
  }

  /// Limpa transações de um período específico
  void clearTransactionsInPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    _transactions.removeWhere((t) {
      return t.date.isAfter(startDate) && t.date.isBefore(endDate);
    });
    notifyListeners();
  }

  /// Retorna estatísticas por categoria de receita
  Map<IncomeCategory, double> getIncomeStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final summary = FinancialService.calculateSummary(
      transactions: _transactions,
      startDate: startDate,
      endDate: endDate,
    );
    return summary.incomeByCategory;
  }

  /// Retorna estatísticas por categoria de despesa
  Map<ExpenseCategory, double> getExpenseStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final summary = FinancialService.calculateSummary(
      transactions: _transactions,
      startDate: startDate,
      endDate: endDate,
    );
    return summary.expenseByCategory;
  }

  /// Retorna transações de uma categoria específica
  List<FinancialTransaction> getTransactionsByIncomeCategory(
    IncomeCategory category,
  ) {
    return _transactions
        .where(
          (t) =>
              t.type == TransactionType.INCOME && t.incomeCategory == category,
        )
        .toList();
  }

  List<FinancialTransaction> getTransactionsByExpenseCategory(
    ExpenseCategory category,
  ) {
    return _transactions
        .where(
          (t) =>
              t.type == TransactionType.EXPENSE &&
              t.expenseCategory == category,
        )
        .toList();
  }

  /// Compara performance entre meses
  Map<String, dynamic> compareLastTwoMonths() {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    return FinancialService.comparePerformance(
      transactions: _transactions,
      period1Start: lastMonthStart,
      period1End: lastMonthEnd,
      period2Start: thisMonthStart,
      period2End: thisMonthEnd,
    );
  }

  /// Exporta transações para Map (para salvar)
  List<Map<String, dynamic>> exportTransactions() {
    return _transactions.map((t) => t.toMap()).toList();
  }

  /// Importa transações de Map (para carregar)
  void importTransactions(List<Map<String, dynamic>> data) {
    _transactions.clear();
    for (final map in data) {
      _transactions.add(FinancialTransaction.fromMap(map));
    }
    _sortTransactions();
    notifyListeners();
  }
}
