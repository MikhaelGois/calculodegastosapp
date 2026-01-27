import '../models/financial_transaction.dart';

/// Resultado de análise financeira
class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final double profitMargin; // %
  final Map<IncomeCategory, double> incomeByCategory;
  final Map<ExpenseCategory, double> expenseByCategory;
  final Map<PaymentMethod, double> byPaymentMethod;
  final int totalTransactions;
  final DateTime startDate;
  final DateTime endDate;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.profitMargin,
    required this.incomeByCategory,
    required this.expenseByCategory,
    required this.byPaymentMethod,
    required this.totalTransactions,
    required this.startDate,
    required this.endDate,
  });

  bool get isProfitable => netProfit > 0;

  String get profitStatus {
    if (netProfit > 0) return 'Lucro';
    if (netProfit < 0) return 'Prejuízo';
    return 'Empate';
  }

  String get profitStatusIcon {
    if (netProfit > 0) return '📈';
    if (netProfit < 0) return '📉';
    return '➖';
  }
}

/// Serviço de gestão financeira
class FinancialService {
  /// Calcula resumo financeiro para um período
  static FinancialSummary calculateSummary({
    required List<FinancialTransaction> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Filtrar por período
    final filteredTransactions = transactions.where((t) {
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    // Calcular totais
    double totalIncome = 0;
    double totalExpense = 0;
    final incomeByCategory = <IncomeCategory, double>{};
    final expenseByCategory = <ExpenseCategory, double>{};
    final byPaymentMethod = <PaymentMethod, double>{};

    for (final transaction in filteredTransactions) {
      if (transaction.type == TransactionType.INCOME) {
        totalIncome += transaction.amount;
        if (transaction.incomeCategory != null) {
          incomeByCategory[transaction.incomeCategory!] =
              (incomeByCategory[transaction.incomeCategory!] ?? 0) +
              transaction.amount;
        }
      } else {
        totalExpense += transaction.amount;
        if (transaction.expenseCategory != null) {
          expenseByCategory[transaction.expenseCategory!] =
              (expenseByCategory[transaction.expenseCategory!] ?? 0) +
              transaction.amount;
        }
      }

      byPaymentMethod[transaction.paymentMethod] =
          (byPaymentMethod[transaction.paymentMethod] ?? 0) +
          transaction.amount;
    }

    final netProfit = totalIncome - totalExpense;
    final profitMargin = totalIncome > 0 ? (netProfit / totalIncome) * 100 : 0;

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netProfit: netProfit,
      profitMargin: profitMargin,
      incomeByCategory: incomeByCategory,
      expenseByCategory: expenseByCategory,
      byPaymentMethod: byPaymentMethod,
      totalTransactions: filteredTransactions.length,
      startDate:
          startDate ??
          (filteredTransactions.isEmpty
              ? DateTime.now()
              : filteredTransactions
                    .map((e) => e.date)
                    .reduce((a, b) => a.isBefore(b) ? a : b)),
      endDate:
          endDate ??
          (filteredTransactions.isEmpty
              ? DateTime.now()
              : filteredTransactions
                    .map((e) => e.date)
                    .reduce((a, b) => a.isAfter(b) ? a : b)),
    );
  }

  /// Retorna transações de hoje
  static List<FinancialTransaction> getTodayTransactions(
    List<FinancialTransaction> transactions,
  ) {
    final today = DateTime.now();
    return transactions.where((t) {
      return t.date.year == today.year &&
          t.date.month == today.month &&
          t.date.day == today.day;
    }).toList();
  }

  /// Retorna transações desta semana
  static List<FinancialTransaction> getWeekTransactions(
    List<FinancialTransaction> transactions,
  ) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return transactions.where((t) => t.date.isAfter(weekStart)).toList();
  }

  /// Retorna transações deste mês
  static List<FinancialTransaction> getMonthTransactions(
    List<FinancialTransaction> transactions,
  ) {
    final now = DateTime.now();
    return transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();
  }

  /// Calcula média diária de lucro
  static double calculateDailyAverageProfit(
    List<FinancialTransaction> transactions,
    int days,
  ) {
    if (days <= 0) return 0;

    final summary = calculateSummary(
      transactions: transactions,
      startDate: DateTime.now().subtract(Duration(days: days)),
    );

    return summary.netProfit / days;
  }

  /// Retorna top despesas por categoria
  static List<MapEntry<ExpenseCategory, double>> getTopExpenses(
    List<FinancialTransaction> transactions, {
    int limit = 5,
  }) {
    final summary = calculateSummary(transactions: transactions);
    final sorted = summary.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  /// Retorna despesas recorrentes próximas
  static List<FinancialTransaction> getUpcomingRecurring(
    List<FinancialTransaction> transactions, {
    int daysAhead = 7,
  }) {
    final now = DateTime.now();
    final limit = now.add(Duration(days: daysAhead));

    return transactions.where((t) {
      return t.isRecurring &&
          t.nextRecurrence != null &&
          t.nextRecurrence!.isAfter(now) &&
          t.nextRecurrence!.isBefore(limit);
    }).toList()..sort((a, b) => a.nextRecurrence!.compareTo(b.nextRecurrence!));
  }

  /// Calcula ponto de equilíbrio (quanto precisa ganhar para cobrir despesas)
  static double calculateBreakEven(
    List<FinancialTransaction> transactions, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final summary = calculateSummary(
      transactions: transactions,
      startDate: startDate,
      endDate: endDate,
    );
    return summary.totalExpense;
  }

  /// Retorna previsão de despesas recorrentes para próximo mês
  static double predictNextMonthExpenses(
    List<FinancialTransaction> transactions,
  ) {
    final recurringExpenses = transactions
        .where((t) => t.type == TransactionType.EXPENSE && t.isRecurring)
        .toList();

    return recurringExpenses.fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Compara performance entre períodos
  static Map<String, dynamic> comparePerformance({
    required List<FinancialTransaction> transactions,
    required DateTime period1Start,
    required DateTime period1End,
    required DateTime period2Start,
    required DateTime period2End,
  }) {
    final summary1 = calculateSummary(
      transactions: transactions,
      startDate: period1Start,
      endDate: period1End,
    );

    final summary2 = calculateSummary(
      transactions: transactions,
      startDate: period2Start,
      endDate: period2End,
    );

    final incomeChange = summary2.totalIncome - summary1.totalIncome;
    final expenseChange = summary2.totalExpense - summary1.totalExpense;
    final profitChange = summary2.netProfit - summary1.netProfit;

    final incomeChangePercent = summary1.totalIncome > 0
        ? (incomeChange / summary1.totalIncome) * 100
        : 0;

    final expenseChangePercent = summary1.totalExpense > 0
        ? (expenseChange / summary1.totalExpense) * 100
        : 0;

    return {
      'period1': summary1,
      'period2': summary2,
      'incomeChange': incomeChange,
      'expenseChange': expenseChange,
      'profitChange': profitChange,
      'incomeChangePercent': incomeChangePercent,
      'expenseChangePercent': expenseChangePercent,
      'improving': profitChange > 0,
    };
  }

  /// Calcula ROI (Return on Investment)
  static double calculateROI({
    required double investment,
    required double returns,
  }) {
    if (investment == 0) return 0;
    return ((returns - investment) / investment) * 100;
  }

  /// Formata valor monetário
  static String formatCurrency(double value, {bool showSign = false}) {
    final sign = showSign ? (value >= 0 ? '+' : '') : '';
    return '$sign R\$ ${value.abs().toStringAsFixed(2)}';
  }
}
