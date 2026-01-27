import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Modelo de localização com endereço e coordenadas
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
  });

  /// Formatar como string para exibição
  String toDisplayString() {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    return '$latitude, $longitude';
  }

  /// Formatar para marca d'água
  String toWatermarkString() {
    final coords =
        '(${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
    if (address != null && address!.isNotEmpty) {
      return '$address\n$coords';
    }
    return coords;
  }
}

/// Serviço de localização
class LocationService {
  static Future<bool> requestLocationPermission() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.granted ||
        status == LocationPermission.whileInUse;
  }

  static Future<bool> hasLocationPermission() async {
    final status = await Geolocator.checkPermission();
    return status == LocationPermission.granted ||
        status == LocationPermission.whileInUse;
  }

  /// Obter localização atual
  static Future<LocationData?> getCurrentLocation() async {
    try {
      // Verificar permissão
      bool hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        hasPermission = await requestLocationPermission();
      }

      if (!hasPermission) {
        return null;
      }

      // Obter posição
      final position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
            ),
          );

      // Obter endereço
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = '${place.street ?? ''} ${place.thoroughfare ?? ''}'.trim();
        }
      } catch (e) {
        // Se falhar em obter endereço, continua sem ele
        print('Erro ao obter endereço: $e');
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        city: placemarks.isNotEmpty ? placemarks.first.locality : null,
        state: placemarks.isNotEmpty
            ? placemarks.first.administrativeArea
            : null,
      );
    } catch (e) {
      print('Erro ao obter localização: $e');
      return null;
    }
  }

  /// Obter endereço a partir de coordenadas
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
    } catch (e) {
      print('Erro ao obter endereço: $e');
    }
    return null;
  }
}
