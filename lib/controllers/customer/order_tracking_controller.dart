import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OrderTrackingController extends GetxController {
  final String orderId;
  final String dropAddress;
  final Future<Map<String, dynamic>?> Function() fetcher;

  OrderTrackingController(
    this.orderId, {
    required this.fetcher,
    this.dropAddress = '',
  });

  final Rxn<LatLng> rider = Rxn<LatLng>();
  final Rxn<LatLng> drop = Rxn<LatLng>();
  final RxList<LatLng> route = <LatLng>[].obs;
  final RxnInt etaMinutes = RxnInt();
  final RxnDouble distanceKm = RxnDouble();
  final RxString areaName = ''.obs;
  final RxString status = ''.obs;
  final RxString riderName = ''.obs;
  final RxString riderMobile = ''.obs;
  final Rxn<DateTime> updatedAt = Rxn<DateTime>();
  final RxBool loaded = false.obs;

  Timer? _timer;
  bool _busy = false;
  bool _geocoding = false;
  int _geocodeTries = 0;
  bool _routeBusy = false;
  LatLng? _routeFrom;
  DateTime? _routeAt;

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchLocation());
  }

  double? _num(dynamic v) {
    if (v == null) return null;
    return v is num ? v.toDouble() : double.tryParse('$v');
  }

  Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  Future<void> fetchLocation() async {
    if (_busy || isClosed) return;
    _busy = true;
    try {
      final d = await fetcher();
      if (d != null && !isClosed) _apply(d);
    } catch (e) {
      debugPrint('[TRACK] error: $e');
    } finally {
      loaded.value = true;
      _busy = false;
    }
  }

  void _apply(Map<String, dynamic> raw) {
    // accept both {success, data:{...}} and the already-unwrapped data
    final d = raw['data'] is Map ? _map(raw['data']) : raw;

    final boy = _map(d['deliveryBoy']);
    final location = d['location'] is Map
        ? _map(d['location'])
        : (boy['currentLocation'] is Map
            ? _map(boy['currentLocation'])
            : _map(boy['location']));

    final lat = _num(
        d['lat'] ?? d['latitude'] ?? location['lat'] ?? location['latitude']);
    final lng = _num(
        d['lng'] ?? d['longitude'] ?? location['lng'] ?? location['longitude']);
    if (lat != null && lng != null) rider.value = LatLng(lat, lng);

    areaName.value =
        (d['areaName'] ?? d['currentArea'] ?? location['areaName'] ?? '')
            .toString();
    status.value = (d['status'] ?? '').toString();

    final upd = d['updatedAt'] ?? location['updatedAt'];
    if (upd != null) updatedAt.value = DateTime.tryParse(upd.toString());

    riderName.value = (boy['name'] ?? boy['fullName'] ?? '').toString();
    riderMobile.value = (boy['mobile'] ?? '').toString();

    final dr = d['drop'];
    if (dr is Map) {
      final dl = _num(dr['lat']);
      final dg = _num(dr['lng']);
      if (dl != null && dg != null) drop.value = LatLng(dl, dg);
    }

    // backend ETA, used until / unless a route-based ETA is available
    final backendEta = _num(_map(d['eta'])['estimatedMinutes']);
    if (backendEta != null && route.length < 2) {
      etaMinutes.value = math.max(1, backendEta.ceil());
    }

    // stop polling once the order is finished
    final s = status.value.toUpperCase();
    if (s == 'DELIVERED' || s == 'REJECTED' || s == 'CANCELLED') {
      _timer?.cancel();
    }

    _maybeGeocodeDrop();
    _maybeLoadRoute();
  }

  /// If the backend sent no drop coordinates, find them from the saved address.
  Future<void> _maybeGeocodeDrop() async {
    if (drop.value != null ||
        _geocoding ||
        _geocodeTries >= 3 ||
        dropAddress.trim().isEmpty) {
      return;
    }
    _geocoding = true;
    _geocodeTries++;
    try {
      final queries = <String>[
        dropAddress,
        if (!dropAddress.toLowerCase().contains('kolhapur'))
          '$dropAddress, Kolhapur, Maharashtra',
      ];
      for (final q in queries) {
        try {
          final list =
              await locationFromAddress(q).timeout(const Duration(seconds: 8));
          if (list.isNotEmpty) {
            drop.value = LatLng(list.first.latitude, list.first.longitude);
            break;
          }
        } catch (e) {
          debugPrint('[TRACK] geocode "$q" failed: $e');
        }
      }
      if (drop.value != null) _maybeLoadRoute(force: true);
    } finally {
      _geocoding = false;
    }
  }

  void _maybeLoadRoute({bool force = false}) {
    final a = rider.value;
    final b = drop.value;
    if (a == null || b == null) return;

    if (!force && _routeFrom != null && route.isNotEmpty) {
      final moved = const Distance().as(LengthUnit.Meter, _routeFrom!, a);
      final age = DateTime.now().difference(_routeAt ?? DateTime(2000));
      if (moved < 40 && age.inSeconds < 45) return;
    }
    _loadRoute(a, b);
  }

  Future<void> _loadRoute(LatLng a, LatLng b) async {
    if (_routeBusy) return;
    _routeBusy = true;
    _routeFrom = a;
    _routeAt = DateTime.now();
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/${a.longitude},${a.latitude};${b.longitude},${b.latitude}?overview=full&geometries=geojson';
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (isClosed) return;
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final r = (j['routes'] as List).first as Map<String, dynamic>;
        final coords = ((r['geometry'] as Map)['coordinates'] as List)
            .map((c) =>
                LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList();
        route.assignAll(coords);
        etaMinutes.value = math.max(1, ((r['duration'] as num) / 60).ceil());
        distanceKm.value = (r['distance'] as num) / 1000;
        return;
      }
    } catch (e) {
      debugPrint('[TRACK] route failed: $e');
    } finally {
      _routeBusy = false;
    }
    if (isClosed) return;
    // fallback: straight line, assume 25 km/h
    final meters = const Distance().as(LengthUnit.Meter, a, b);
    route.assignAll([a, b]);
    distanceKm.value = meters / 1000;
    etaMinutes.value = math.max(1, ((meters / 1000) / 25 * 60).ceil());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
