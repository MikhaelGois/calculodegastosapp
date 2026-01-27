import 'package:url_launcher/url_launcher.dart';

class MapsService {
  static Future<void> openMapsWithAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = 'https://www.google.com/maps/search/$encodedAddress';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openMapsWithCoordinates(
    double latitude,
    double longitude, {
    String? label,
  }) async {
    final url =
        'https://www.google.com/maps/@$latitude,$longitude,15z${label != null ? '?q=$label' : ''}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openMapsDirections(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    final url =
        'https://www.google.com/maps/dir/$startLat,$startLng/$endLat,$endLng';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  static String generateMapsLink(String address) {
    return 'https://www.google.com/maps/search/${Uri.encodeComponent(address)}';
  }

  static String generateMapsCoordsLink(double latitude, double longitude) {
    return 'https://www.google.com/maps/@$latitude,$longitude,15z';
  }
}
