import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/calculation_result.dart';
import '../services/storage_service.dart';
import '../services/calculation_service.dart';

class VehicleProvider extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  CalculationResult? _lastCalculation;
  bool _isLoading = false;

  // Getters
  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  CalculationResult? get lastCalculation => _lastCalculation;
  bool get isLoading => _isLoading;

  // Métodos
  Future<void> loadVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      _vehicles = StorageService.getAllVehicles();
      if (_vehicles.isNotEmpty && _selectedVehicle == null) {
        _selectedVehicle = _vehicles.first;
      }
    } catch (e) {
      debugPrint('Erro ao carregar veículos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await StorageService.addVehicle(vehicle);
      _vehicles.add(vehicle);
      _selectedVehicle = vehicle;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar veículo: $e');
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      await StorageService.updateVehicle(vehicle);
      final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index >= 0) {
        _vehicles[index] = vehicle;
        if (_selectedVehicle?.id == vehicle.id) {
          _selectedVehicle = vehicle;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao atualizar veículo: $e');
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await StorageService.deleteVehicle(vehicleId);
      _vehicles.removeWhere((v) => v.id == vehicleId);
      if (_selectedVehicle?.id == vehicleId) {
        _selectedVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar veículo: $e');
    }
  }

  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  void calculateResults() {
    if (_selectedVehicle != null) {
      _lastCalculation = CalculationService.calculate(_selectedVehicle!);
      notifyListeners();
    }
  }

  Map<String, double> getDetailedBreakdown() {
    if (_selectedVehicle == null) return {};
    return CalculationService.getDetailedBreakdown(_selectedVehicle!);
  }
}
