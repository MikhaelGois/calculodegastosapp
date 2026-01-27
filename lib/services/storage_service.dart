import 'package:hive_flutter/hive_flutter.dart';
import '../models/vehicle.dart';
import '../models/trip.dart';

class StorageService {
  static const String vehiclesBoxName = 'vehicles';
  static const String tripsBoxName = 'trips';
  static const String notificationsBoxName = 'notifications';

  static late Box<Map> vehiclesBox;
  static late Box<Map> tripsBox;
  static late Box<Map> notificationsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    vehiclesBox = await Hive.openBox<Map>(vehiclesBoxName);
    tripsBox = await Hive.openBox<Map>(tripsBoxName);
    notificationsBox = await Hive.openBox<Map>(notificationsBoxName);
  }

  // ========== VEHICLES ==========
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

  // ========== TRIPS ==========
  static Future<void> addTrip(Trip trip) async {
    await tripsBox.put(trip.id, trip.toMap());
  }

  static Future<void> updateTrip(Trip trip) async {
    await tripsBox.put(trip.id, trip.toMap());
  }

  static Future<void> deleteTrip(String tripId) async {
    await tripsBox.delete(tripId);
  }

  static List<Trip> getAllTrips() {
    return tripsBox.values
        .map((map) => Trip.fromMap(Map<String, dynamic>.from(map)))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  static List<Trip> getTripsByVehicle(String vehicleId) {
    return getAllTrips().where((trip) => trip.vehicleId == vehicleId).toList();
  }

  static Trip? getTrip(String tripId) {
    final map = tripsBox.get(tripId);
    if (map == null) return null;
    return Trip.fromMap(Map<String, dynamic>.from(map));
  }

  static List<Trip> getTripsByDateRange(DateTime start, DateTime end) {
    return getAllTrips()
        .where(
          (trip) =>
              trip.startTime.isAfter(start) && trip.startTime.isBefore(end),
        )
        .toList();
  }

  // ========== NOTIFICATIONS ==========
  static Future<void> addNotification(TripNotification notification) async {
    await notificationsBox.put(notification.id, notification.toMap());
  }

  static List<TripNotification> getAllNotifications() {
    return notificationsBox.values
        .map((map) => TripNotification.fromMap(Map<String, dynamic>.from(map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<TripNotification> getUnreadNotifications() {
    return getAllNotifications().where((n) => !n.isRead).toList();
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    final map = notificationsBox.get(notificationId);
    if (map != null) {
      final notification = TripNotification.fromMap(
        Map<String, dynamic>.from(map),
      );
      await notificationsBox.put(
        notificationId,
        TripNotification(
          id: notification.id,
          tripId: notification.tripId,
          title: notification.title,
          message: notification.message,
          createdAt: notification.createdAt,
          isRead: true,
        ).toMap(),
      );
    }
  }

  // ========== GENERAL ==========
  static Future<void> clear() async {
    await vehiclesBox.clear();
    await tripsBox.clear();
    await notificationsBox.clear();
  }
}
