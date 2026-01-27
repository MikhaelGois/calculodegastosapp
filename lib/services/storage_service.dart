import 'package:hive_flutter/hive_flutter.dart';
import '../models/vehicle.dart';

class StorageService {
  static const String vehiclesBoxName = 'vehicles';
  static late Box<Map> vehiclesBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    vehiclesBox = await Hive.openBox<Map>(vehiclesBoxName);
  }

  static Future<void> addVehicle(Vehicle vehicle) async {
    await vehiclesBox.put(vehicle.id, vehicle.toMap());
  }

  static Future<void> updateVehicle(Vehicle vehicle) async {
    await vehiclesBox.put(vehicle.id, vehicle.toMap());
  }

  static Future<void> deleteVehicle(String vehicleId) async {
    await vehiclesBox.delete(vehicleId);
  }

  static List<Vehicle> getAllVehicles() {
    return vehiclesBox.values
        .map((map) => Vehicle.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  static Vehicle? getVehicle(String vehicleId) {
    final map = vehiclesBox.get(vehicleId);
    if (map == null) return null;
    return Vehicle.fromMap(Map<String, dynamic>.from(map));
  }

  static Future<void> clear() async {
    await vehiclesBox.clear();
  }
}
