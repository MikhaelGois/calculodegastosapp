import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/trip_model.dart';
import '../models/expense_model.dart';
import '../models/cost_config_model.dart';

class LocalStorageService {
  static const String _tripsKey = 'trips';
  static const String _expensesKey = 'expenses';
  static const String _costConfigKey = 'cost_config';

  // Salvar lista de corridas
  static Future<void> saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tripsJson =
        trips.map((trip) => jsonEncode(trip.toJson())).toList();
    await prefs.setStringList(_tripsKey, tripsJson);
  }

  // Carregar lista de corridas
  static Future<List<Trip>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = prefs.getStringList(_tripsKey) ?? [];
    return tripsJson
        .map((jsonString) => Trip.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  // Salvar lista de despesas
  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expensesJson =
        expenses.map((expense) => jsonEncode(expense.toJson())).toList();
    await prefs.setStringList(_expensesKey, expensesJson);
  }

  // Carregar lista de despesas
  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getStringList(_expensesKey) ?? [];
    return expensesJson
        .map((jsonString) => Expense.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  // Salvar configuração de custos
  static Future<void> saveCostConfig(CostConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_costConfigKey, jsonEncode(config.toJson()));
  }

  // Carregar configuração de custos
  static Future<CostConfig?> loadCostConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_costConfigKey);

    if (configJson != null) {
      return CostConfig.fromJson(jsonDecode(configJson));
    }
    return null;
  }

  // Limpar todos os dados
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripsKey);
    await prefs.remove(_expensesKey);
    await prefs.remove(_costConfigKey);
  }
}
