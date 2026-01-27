import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/financial_transaction.dart';
import '../providers/financial_provider.dart';

/// Tela de formulário para adicionar/editar transação
class TransactionFormScreen extends StatefulWidget {
  final FinancialTransaction? transaction;

  const TransactionFormScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late TransactionType _selectedType;
  late DateTime _selectedDate;
  late PaymentMethod _selectedPaymentMethod;
  IncomeCategory? _selectedIncomeCategory;
  ExpenseCategory? _selectedExpenseCategory;
  bool _isRecurring = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final transaction = widget.transaction!;
      _selectedType = transaction.type;
      _selectedDate = transaction.date;
      _selectedPaymentMethod = transaction.paymentMethod;
      _selectedIncomeCategory = transaction.incomeCategory;
      _selectedExpenseCategory = transaction.expenseCategory;
      _isRecurring = transaction.isRecurring;
      _descriptionController.text = transaction.description;
      _amountController.text = transaction.amount.toStringAsFixed(2);
      _notesController.text = transaction.notes ?? '';
    } else {
      _selectedType = TransactionType.EXPENSE;
      _selectedDate = DateTime.now();
      _selectedPaymentMethod = PaymentMethod.CASH;
      _selectedExpenseCategory = ExpenseCategory.FUEL;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Transação' : 'Nova Transação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTransaction,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo de transação
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton(
                            TransactionType.INCOME,
                            '💰 Receita',
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeButton(
                            TransactionType.EXPENSE,
                            '💸 Despesa',
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Descrição
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex: Abastecimento, Corrida Uber...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe uma descrição';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Valor
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                hintText: '0,00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe um valor';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Categoria
            DropdownButtonFormField(
              value: _selectedType == TransactionType.INCOME
                  ? _selectedIncomeCategory
                  : _selectedExpenseCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _selectedType == TransactionType.INCOME
                  ? IncomeCategory.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              '${category.icon} ${category.displayName}',
                            ),
                          ),
                        )
                        .toList()
                  : ExpenseCategory.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              '${category.icon} ${category.displayName}',
                            ),
                          ),
                        )
                        .toList(),
              onChanged: (value) {
                setState(() {
                  if (_selectedType == TransactionType.INCOME) {
                    _selectedIncomeCategory = value as IncomeCategory?;
                  } else {
                    _selectedExpenseCategory = value as ExpenseCategory?;
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecione uma categoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Método de pagamento
            DropdownButtonFormField<PaymentMethod>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Método de Pagamento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: PaymentMethod.values
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text('${method.icon} ${method.displayName}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Data
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recorrente
            Card(
              child: SwitchListTile(
                title: const Text('Transação Recorrente'),
                subtitle: const Text('Repetir mensalmente'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
                secondary: const Icon(Icons.repeat),
              ),
            ),
            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Informações adicionais...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Botão salvar
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isEditing ? 'ATUALIZAR TRANSAÇÃO' : 'ADICIONAR TRANSAÇÃO',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String label, Color color) {
    final isSelected = _selectedType == type;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedType = type;
          // Reset category when changing type
          if (type == TransactionType.INCOME) {
            _selectedIncomeCategory = IncomeCategory.RIDE;
            _selectedExpenseCategory = null;
          } else {
            _selectedExpenseCategory = ExpenseCategory.FUEL;
            _selectedIncomeCategory = null;
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.grey[700],
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(label),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FinancialProvider>(context, listen: false);

      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;
      final notes = _notesController.text.isEmpty
          ? null
          : _notesController.text;

      final transaction = FinancialTransaction.create(
        type: _selectedType,
        amount: amount,
        date: _selectedDate,
        description: description,
        paymentMethod: _selectedPaymentMethod,
        incomeCategory: _selectedIncomeCategory,
        expenseCategory: _selectedExpenseCategory,
        notes: notes,
        isRecurring: _isRecurring,
      );

      if (_isEditing) {
        provider.updateTransaction(
          transaction.copyWith(id: widget.transaction!.id),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transação atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        provider.addTransaction(transaction);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transação adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
