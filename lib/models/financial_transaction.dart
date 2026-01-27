import 'package:uuid/uuid.dart';

/// Tipo de transação financeira
enum TransactionType {
  INCOME, // Receita
  EXPENSE, // Despesa
}

/// Categoria de receita
enum IncomeCategory {
  RIDE, // Corrida
  TIP, // Gorjeta
  BONUS, // Bônus
  REIMBURSEMENT, // Reembolso
  OTHER, // Outro
}

/// Categoria de despesa
enum ExpenseCategory {
  FUEL, // Combustível
  MAINTENANCE, // Manutenção
  INSURANCE, // Seguro
  CAR_WASH, // Lavagem
  PARKING, // Estacionamento
  TOLL, // Pedágio
  FOOD, // Alimentação
  PHONE, // Telefone/Internet
  APP_FEE, // Taxa do app
  OTHER, // Outro
}

/// Método de pagamento
enum PaymentMethod {
  CASH, // Dinheiro
  DEBIT_CARD, // Cartão de débito
  CREDIT_CARD, // Cartão de crédito
  PIX, // PIX
  APP_WALLET, // Carteira do app
  OTHER, // Outro
}

/// Extensão para nomes localizados
extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.INCOME:
        return 'Receita';
      case TransactionType.EXPENSE:
        return 'Despesa';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.INCOME:
        return '💰';
      case TransactionType.EXPENSE:
        return '💸';
    }
  }
}

extension IncomeCategoryExtension on IncomeCategory {
  String get displayName {
    switch (this) {
      case IncomeCategory.RIDE:
        return 'Corrida';
      case IncomeCategory.TIP:
        return 'Gorjeta';
      case IncomeCategory.BONUS:
        return 'Bônus';
      case IncomeCategory.REIMBURSEMENT:
        return 'Reembolso';
      case IncomeCategory.OTHER:
        return 'Outro';
    }
  }

  String get icon {
    switch (this) {
      case IncomeCategory.RIDE:
        return '🚗';
      case IncomeCategory.TIP:
        return '💵';
      case IncomeCategory.BONUS:
        return '🎁';
      case IncomeCategory.REIMBURSEMENT:
        return '↩️';
      case IncomeCategory.OTHER:
        return '📝';
    }
  }
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.FUEL:
        return 'Combustível';
      case ExpenseCategory.MAINTENANCE:
        return 'Manutenção';
      case ExpenseCategory.INSURANCE:
        return 'Seguro';
      case ExpenseCategory.CAR_WASH:
        return 'Lavagem';
      case ExpenseCategory.PARKING:
        return 'Estacionamento';
      case ExpenseCategory.TOLL:
        return 'Pedágio';
      case ExpenseCategory.FOOD:
        return 'Alimentação';
      case ExpenseCategory.PHONE:
        return 'Telefone/Internet';
      case ExpenseCategory.APP_FEE:
        return 'Taxa do App';
      case ExpenseCategory.OTHER:
        return 'Outro';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.FUEL:
        return '⛽';
      case ExpenseCategory.MAINTENANCE:
        return '🔧';
      case ExpenseCategory.INSURANCE:
        return '🛡️';
      case ExpenseCategory.CAR_WASH:
        return '🚿';
      case ExpenseCategory.PARKING:
        return '🅿️';
      case ExpenseCategory.TOLL:
        return '🛣️';
      case ExpenseCategory.FOOD:
        return '🍔';
      case ExpenseCategory.PHONE:
        return '📱';
      case ExpenseCategory.APP_FEE:
        return '📊';
      case ExpenseCategory.OTHER:
        return '📝';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.CASH:
        return 'Dinheiro';
      case PaymentMethod.DEBIT_CARD:
        return 'Débito';
      case PaymentMethod.CREDIT_CARD:
        return 'Crédito';
      case PaymentMethod.PIX:
        return 'PIX';
      case PaymentMethod.APP_WALLET:
        return 'Carteira App';
      case PaymentMethod.OTHER:
        return 'Outro';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.CASH:
        return '💵';
      case PaymentMethod.DEBIT_CARD:
        return '💳';
      case PaymentMethod.CREDIT_CARD:
        return '💳';
      case PaymentMethod.PIX:
        return '📲';
      case PaymentMethod.APP_WALLET:
        return '👛';
      case PaymentMethod.OTHER:
        return '💰';
    }
  }
}

/// Transação financeira
class FinancialTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description;
  final PaymentMethod paymentMethod;

  // Para receitas
  final IncomeCategory? incomeCategory;
  final String? rideId; // Link para corrida específica

  // Para despesas
  final ExpenseCategory? expenseCategory;
  final String? vehicleId; // Link para veículo
  final double? odometer; // Km no odômetro

  // Informações adicionais
  final String? notes;
  final List<String>? attachments; // Paths de fotos de recibos
  final bool isRecurring; // Se é recorrente (ex: seguro mensal)
  final DateTime? nextRecurrence; // Próxima data de recorrência

  FinancialTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.paymentMethod,
    this.incomeCategory,
    this.rideId,
    this.expenseCategory,
    this.vehicleId,
    this.odometer,
    this.notes,
    this.attachments,
    this.isRecurring = false,
    this.nextRecurrence,
  });

  /// Cria nova transação com UUID
  factory FinancialTransaction.create({
    required TransactionType type,
    required double amount,
    required DateTime date,
    required String description,
    required PaymentMethod paymentMethod,
    IncomeCategory? incomeCategory,
    String? rideId,
    ExpenseCategory? expenseCategory,
    String? vehicleId,
    double? odometer,
    String? notes,
    List<String>? attachments,
    bool isRecurring = false,
    DateTime? nextRecurrence,
  }) {
    return FinancialTransaction(
      id: const Uuid().v4(),
      type: type,
      amount: amount,
      date: date,
      description: description,
      paymentMethod: paymentMethod,
      incomeCategory: incomeCategory,
      rideId: rideId,
      expenseCategory: expenseCategory,
      vehicleId: vehicleId,
      odometer: odometer,
      notes: notes,
      attachments: attachments,
      isRecurring: isRecurring,
      nextRecurrence: nextRecurrence,
    );
  }

  /// Ícone da categoria
  String get categoryIcon {
    if (type == TransactionType.INCOME && incomeCategory != null) {
      return incomeCategory!.icon;
    } else if (type == TransactionType.EXPENSE && expenseCategory != null) {
      return expenseCategory!.icon;
    }
    return '📝';
  }

  /// Nome da categoria
  String get categoryName {
    if (type == TransactionType.INCOME && incomeCategory != null) {
      return incomeCategory!.displayName;
    } else if (type == TransactionType.EXPENSE && expenseCategory != null) {
      return expenseCategory!.displayName;
    }
    return 'Sem categoria';
  }

  /// Serialização para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'paymentMethod': paymentMethod.index,
      'incomeCategory': incomeCategory?.index,
      'rideId': rideId,
      'expenseCategory': expenseCategory?.index,
      'vehicleId': vehicleId,
      'odometer': odometer,
      'notes': notes,
      'attachments': attachments,
      'isRecurring': isRecurring,
      'nextRecurrence': nextRecurrence?.toIso8601String(),
    };
  }

  /// Desserialização de Map
  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    return FinancialTransaction(
      id: map['id'] as String,
      type: TransactionType.values[map['type'] as int],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      paymentMethod: PaymentMethod.values[map['paymentMethod'] as int],
      incomeCategory: map['incomeCategory'] != null
          ? IncomeCategory.values[map['incomeCategory'] as int]
          : null,
      rideId: map['rideId'] as String?,
      expenseCategory: map['expenseCategory'] != null
          ? ExpenseCategory.values[map['expenseCategory'] as int]
          : null,
      vehicleId: map['vehicleId'] as String?,
      odometer: map['odometer'] != null
          ? (map['odometer'] as num).toDouble()
          : null,
      notes: map['notes'] as String?,
      attachments: map['attachments'] != null
          ? List<String>.from(map['attachments'] as List)
          : null,
      isRecurring: map['isRecurring'] as bool? ?? false,
      nextRecurrence: map['nextRecurrence'] != null
          ? DateTime.parse(map['nextRecurrence'] as String)
          : null,
    );
  }

  /// Cópia com modificações
  FinancialTransaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? description,
    PaymentMethod? paymentMethod,
    IncomeCategory? incomeCategory,
    String? rideId,
    ExpenseCategory? expenseCategory,
    String? vehicleId,
    double? odometer,
    String? notes,
    List<String>? attachments,
    bool? isRecurring,
    DateTime? nextRecurrence,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      incomeCategory: incomeCategory ?? this.incomeCategory,
      rideId: rideId ?? this.rideId,
      expenseCategory: expenseCategory ?? this.expenseCategory,
      vehicleId: vehicleId ?? this.vehicleId,
      odometer: odometer ?? this.odometer,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      isRecurring: isRecurring ?? this.isRecurring,
      nextRecurrence: nextRecurrence ?? this.nextRecurrence,
    );
  }
}
