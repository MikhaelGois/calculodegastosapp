import 'package:intl/intl.dart';

class FormatUtils {
  static String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ').format(value);
  }

  static String formatNumber(double value, {int decimalPlaces = 2}) {
    return NumberFormat('#,##0.${'0' * decimalPlaces}', 'pt_BR').format(value);
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String formatKm(double km) {
    return '${km.toStringAsFixed(1)} km';
  }

  static String formatHours(double hours) {
    return '${hours.toStringAsFixed(1)} h';
  }
}

class ValidationUtils {
  static bool isValidNumber(String value) {
    if (value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  static bool isValidEmail(String value) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value);
  }

  static String? validateNotEmpty(String value) {
    return value.isEmpty ? 'Este campo é obrigatório' : null;
  }

  static String? validateNumber(String value) {
    if (value.isEmpty) return 'Este campo é obrigatório';
    if (double.tryParse(value) == null) return 'Insira um número válido';
    if (double.parse(value) < 0) return 'O valor não pode ser negativo';
    return null;
  }
}
