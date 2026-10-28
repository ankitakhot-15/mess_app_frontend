import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LiveLocation {
  final double lat;
  final double lng;
  final String areaName;
  const LiveLocation(this.lat, this.lng, this.areaName);
}

/// GPS for the delivery boy. Returns null if permission / GPS is not available.
class LocationService {
  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  Future<LiveLocation?> current({String fallbackArea = ''}) async {
    try {
      if (!await _ensurePermission()) return null;
      final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      var area = fallbackArea;
      try {
        final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (marks.isNotEmpty) {
          final m = marks.first;
          final name = (m.subLocality?.isNotEmpty ?? false)
              ? m.subLocality!
              : ((m.locality?.isNotEmpty ?? false) ? m.locality! : '');
          if (name.isNotEmpty) area = name;
        }
      } catch (_) {/* keep fallback area */}
      return LiveLocation(pos.latitude, pos.longitude, area);
    } catch (_) {
      return null;
    }
  }
}
