import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double lat;
  final double lng;
  final String areaName;
  const LocationData({
    required this.lat,
    required this.lng,
    required this.areaName,
  });
}

class LocationService {
  /// Current GPS position + area name. Returns null if location is off,
  /// permission is missing, or GPS times out.
  Future<LocationData?> current({String fallbackArea = ''}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final area =
          await areaFrom(pos.latitude, pos.longitude, fallback: fallbackArea);
      return LocationData(
          lat: pos.latitude, lng: pos.longitude, areaName: area);
    } catch (_) {
      return null;
    }
  }

  /// Short area name, e.g. "Sarnobatwadi". Used for the API and the UI.
  static Future<String> areaFrom(double lat, double lng,
      {String fallback = ''}) async {
    try {
      final list = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 8));
      if (list.isEmpty) return fallback;
      final p = list.first;
      if ((p.subLocality ?? '').isNotEmpty) return p.subLocality!;
      if ((p.locality ?? '').isNotEmpty) return p.locality!;
      return fallback;
    } catch (_) {
      return fallback;
    }
  }
}
