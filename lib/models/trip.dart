import 'package:uuid/uuid.dart';

class Trip {
  final String id;
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // em km
  final double totalCost;
  final double earnings;
  final String? startAddress;
  final String? endAddress;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final PassengerRating? passengerRating;
  final String? notes;

  Trip({
    String? id,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.totalCost,
    required this.earnings,
    this.startAddress,
    this.endAddress,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.passengerRating,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Duration get duration => endTime.difference(startTime);

  double get avgSpeed => distance / (duration.inMinutes / 60) > 0
      ? distance / (duration.inMinutes / 60)
      : 0;

  double get valuePerKm => distance > 0 ? totalCost / distance : 0;

  double get valuePerHour =>
      duration.inMinutes > 0 ? totalCost / (duration.inMinutes / 60) : 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distance': distance,
      'totalCost': totalCost,
      'earnings': earnings,
      'startAddress': startAddress,
      'endAddress': endAddress,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'passengerRating': passengerRating?.toMap(),
      'notes': notes,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      vehicleId: map['vehicleId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      distance: (map['distance'] ?? 0).toDouble(),
      totalCost: (map['totalCost'] ?? 0).toDouble(),
      earnings: (map['earnings'] ?? 0).toDouble(),
      startAddress: map['startAddress'],
      endAddress: map['endAddress'],
      startLatitude: map['startLatitude']?.toDouble(),
      startLongitude: map['startLongitude']?.toDouble(),
      endLatitude: map['endLatitude']?.toDouble(),
      endLongitude: map['endLongitude']?.toDouble(),
      passengerRating: map['passengerRating'] != null
          ? PassengerRating.fromMap(
              Map<String, dynamic>.from(map['passengerRating']),
            )
          : null,
      notes: map['notes'],
    );
  }
}

class PassengerRating {
  final double stars; // 1-5
  final String? comment;
  final DateTime ratedAt;

  PassengerRating({required this.stars, this.comment, DateTime? ratedAt})
    : ratedAt = ratedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'stars': stars,
      'comment': comment,
      'ratedAt': ratedAt.toIso8601String(),
    };
  }

  factory PassengerRating.fromMap(Map<String, dynamic> map) {
    return PassengerRating(
      stars: (map['stars'] ?? 5).toDouble(),
      comment: map['comment'],
      ratedAt: DateTime.parse(map['ratedAt']),
    );
  }
}

class TripNotification {
  final String id;
  final String tripId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  TripNotification({
    String? id,
    required this.tripId,
    required this.title,
    required this.message,
    DateTime? createdAt,
    this.isRead = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory TripNotification.fromMap(Map<String, dynamic> map) {
    return TripNotification(
      id: map['id'],
      tripId: map['tripId'],
      title: map['title'],
      message: map['message'],
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
    );
  }
}
