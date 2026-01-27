import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<Trip> _trips = [];
  List<TripNotification> _notifications = [];
  bool _isLoading = false;

  // Getters
  List<Trip> get trips => _trips;
  List<TripNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  // Métodos para Trips
  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trips = StorageService.getAllTrips();
    } catch (e) {
      debugPrint('Erro ao carregar trips: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTrip(Trip trip) async {
    try {
      await StorageService.addTrip(trip);
      _trips.insert(0, trip); // Adiciona no início (mais recente)
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar trip: $e');
    }
  }

  Future<void> updateTrip(Trip trip) async {
    try {
      await StorageService.updateTrip(trip);
      final index = _trips.indexWhere((t) => t.id == trip.id);
      if (index >= 0) {
        _trips[index] = trip;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao atualizar trip: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await StorageService.deleteTrip(tripId);
      _trips.removeWhere((t) => t.id == tripId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar trip: $e');
    }
  }

  List<Trip> getTripsByVehicle(String vehicleId) {
    return _trips.where((t) => t.vehicleId == vehicleId).toList();
  }

  List<Trip> getTripsByDateRange(DateTime start, DateTime end) {
    return _trips
        .where((t) => t.startTime.isAfter(start) && t.startTime.isBefore(end))
        .toList();
  }

  double getTotalEarningsByVehicle(String vehicleId) {
    return getTripsByVehicle(vehicleId)
        .fold(0.0, (sum, trip) => sum + trip.earnings);
  }

  double getTotalDistanceByVehicle(String vehicleId) {
    return getTripsByVehicle(vehicleId)
        .fold(0.0, (sum, trip) => sum + trip.distance);
  }

  // Métodos para Notifications
  Future<void> loadNotifications() async {
    try {
      _notifications = StorageService.getAllNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar notificações: $e');
    }
  }

  Future<void> addNotification(TripNotification notification) async {
    try {
      await StorageService.addNotification(notification);
      _notifications.insert(0, notification);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar notificação: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await StorageService.markNotificationAsRead(notificationId);
      final index =
          _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        final notif = _notifications[index];
        _notifications[index] = TripNotification(
          id: notif.id,
          tripId: notif.tripId,
          title: notif.title,
          message: notif.message,
          createdAt: notif.createdAt,
          isRead: true,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao marcar notificação como lida: $e');
    }
  }

  List<TripNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Estatísticas
  Map<String, dynamic> getStatistics(String vehicleId) {
    final vehicleTrips = getTripsByVehicle(vehicleId);
    if (vehicleTrips.isEmpty) {
      return {
        'totalTrips': 0,
        'totalDistance': 0.0,
        'totalEarnings': 0.0,
        'avgDistance': 0.0,
        'avgEarnings': 0.0,
        'avgRating': 0.0,
      };
    }

    final totalDistance = getTotalDistanceByVehicle(vehicleId);
    final totalEarnings = getTotalEarningsByVehicle(vehicleId);
    final avgRating = vehicleTrips
            .where((t) => t.passengerRating != null)
            .fold<double>(0, (sum, t) => sum + (t.passengerRating?.stars ?? 0)) /
        (vehicleTrips.where((t) => t.passengerRating != null).length > 0
            ? vehicleTrips.where((t) => t.passengerRating != null).length
            : 1);

    return {
      'totalTrips': vehicleTrips.length,
      'totalDistance': totalDistance,
      'totalEarnings': totalEarnings,
      'avgDistance': totalDistance / vehicleTrips.length,
      'avgEarnings': totalEarnings / vehicleTrips.length,
      'avgRating': avgRating,
    };
  }
}
