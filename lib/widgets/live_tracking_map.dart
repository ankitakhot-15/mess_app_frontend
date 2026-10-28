import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'live_location_card.dart'; // for LiveLocation

/// Shows the delivery boy's live position on an OpenStreetMap map.
/// [fetch] returns the latest location from your tracking API.
class LiveTrackingMap extends StatefulWidget {
  final Future<LiveLocation?> Function() fetch;
  final Duration interval;
  final double height;

  const LiveTrackingMap({
    super.key,
    required this.fetch,
    this.interval = const Duration(seconds: 10),
    this.height = 260,
  });

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  final MapController _map = MapController();
  Timer? _timer;
  LatLng? _pos;
  bool _mapReady = false;
  bool _busy = false; // prevents overlapping requests
  bool _firstTry = false; // true once the first fetch has finished

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(widget.interval, (_) => _refresh());
  }

  Future<void> _refresh() async {
    if (_busy) return;
    _busy = true;
    try {
      final data = await widget.fetch();
      if (!mounted) return;
      if (data != null) {
        final p = LatLng(data.lat, data.lng);
        setState(() {
          _pos = p;
          _firstTry = true;
        });
        if (_mapReady)
          _map.move(p, _map.camera.zoom); // follow the delivery boy
      } else if (!_firstTry) {
        setState(() => _firstTry = true);
      }
    } catch (_) {
      if (mounted && !_firstTry) setState(() => _firstTry = true);
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _map.dispose();
    super.dispose();
  }

  Widget _placeholder() {
    if (!_firstTry) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange));
    }
    return Center(
      child: Text('डिलिव्हरी बॉयचे लोकेशन अजून उपलब्ध नाही',
          style: AppTextStyles.caption),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: widget.height,
        child: _pos == null
            ? Container(color: AppColors.white, child: _placeholder())
            : FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: _pos!,
                  initialZoom: 16,
                  onMapReady: () => _mapReady = true,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.mayechi_chav', // see note below
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pos!,
                        width: 48,
                        height: 48,
                        child: const Icon(Icons.two_wheeler_rounded,
                            size: 40, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
