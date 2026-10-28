import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/customer/order_tracking_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../repository/tracking_repository.dart';

const String kTileUserAgent = 'com.example.mayechi_chav';
const String kTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String dropAddress;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.dropAddress = '',
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final OrderTrackingController c;
  final MapController _map = MapController();
  late final AnimationController _anim;
  final List<Worker> _workers = [];

  LatLng? _shown; // rider position currently drawn (animated)
  LatLng? _from;
  LatLng? _to;
  bool _mapReady = false;
  bool _fitted = false;
  bool _follow = false; // camera follows the rider
  int _tileErrors = 0;
  bool _tileBanner = false;

  @override
  void initState() {
    super.initState();
    c = Get.put(
      OrderTrackingController(
        widget.orderId,
        dropAddress: widget.dropAddress,
        fetcher: () => TrackingRepository().track(widget.orderId),
      ),
      tag: widget.orderId,
    );

    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..addListener(() {
        if (!mounted || _from == null || _to == null) return;
        final t = Curves.easeInOut.transform(_anim.value);
        final p = LatLng(
          _from!.latitude + (_to!.latitude - _from!.latitude) * t,
          _from!.longitude + (_to!.longitude - _from!.longitude) * t,
        );
        setState(() => _shown = p);
        if (_follow && _mapReady) {
          _map.move(p, _map.camera.zoom);
        }
      });

    _workers.addAll([
      ever<LatLng?>(c.rider, _onRider),
      ever<LatLng?>(c.drop, (_) {
        if (!mounted) return;
        setState(() {});
        _fit();
      }),
      ever<List<LatLng>>(c.route, (_) {
        if (!mounted) return;
        setState(() {});
      }),
    ]);

    // the controller may already have data before the workers were attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && c.rider.value != null) _onRider(c.rider.value);
    });
  }

  void _onRider(LatLng? p) {
    if (!mounted || p == null) return;
    debugPrint('[RIDER] position ${p.latitude}, ${p.longitude}');
    if (_shown == null) {
      setState(() => _shown = p);
      _fit();
      return;
    }
    _from = _shown;
    _to = p;
    _anim.forward(from: 0); // glide to the new position
  }

  void _fit({bool force = false}) {
    if (!_mapReady || !mounted || (_fitted && !force)) return;
    final pts = <LatLng>[
      if (_shown != null) _shown!,
      if (c.drop.value != null) c.drop.value!,
    ];
    if (pts.isEmpty) return;
    try {
      if (pts.length == 1) {
        _fitted = force;
        _map.move(pts.first, 16);
      } else {
        _fitted = true;
        final h = MediaQuery.of(context).size.height;
        final bottomPad = (h * 0.42).clamp(200.0, 420.0);
        _map.fitCamera(CameraFit.coordinates(
          coordinates: pts,
          padding: EdgeInsets.fromLTRB(50, 110, 50, bottomPad),
          maxZoom: 17,
        ));
      }
    } catch (e) {
      debugPrint('[MAP] fit failed: $e');
      _map.move(pts.first, 15);
    }
  }

  void _onTileError(Object error) {
    _tileErrors++;
    debugPrint('[MAP] tile error: $error');
    if (_tileErrors >= 3 && !_tileBanner && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _tileBanner = true);
      });
    }
  }

  @override
  void dispose() {
    for (final w in _workers) {
      w.dispose();
    }
    _anim.dispose();
    _map.dispose();
    Get.delete<OrderTrackingController>(tag: widget.orderId);
    super.dispose();
  }

  int _step(String s) {
    final n = s.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    if (n.contains('deliver') && !n.contains('out')) return 2;
    if (n.contains('out')) return 1;
    return 0;
  }

  Future<void> _call(String mobile) async {
    if (mobile.isEmpty) return;
    await launchUrl(Uri.parse('tel:$mobile'));
  }

  String _hhmm(DateTime d) {
    final l = d.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  // ------------------------------------------------------------------ UI
  Widget _mapView() {
    final dropPoint = c.drop.value;
    final routePoints = c.route.toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        // always-visible background, so the screen is never empty
        CustomPaint(painter: _GridPainter()),
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: const LatLng(16.705, 74.2433), // Kolhapur
            initialZoom: 14,
            backgroundColor: Colors.transparent,
            onMapReady: () {
              _mapReady = true;
              _fit();
            },
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture && _follow && mounted) {
                setState(() => _follow = false);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: kTileUrl,
              userAgentPackageName: kTileUserAgent,
              errorTileCallback: (tile, error, stack) => _onTileError(error),
            ),
            if (routePoints.length >= 2)
              PolylineLayer(polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 5,
                  color: AppColors.primaryGreen,
                ),
              ]),
            MarkerLayer(markers: [
              if (dropPoint != null)
                Marker(
                  point: dropPoint,
                  width: 48,
                  height: 48,
                  child: const Icon(Icons.location_on_rounded,
                      size: 44, color: AppColors.primaryOrange),
                ),
              if (_shown != null)
                Marker(
                  point: _shown!,
                  width: 54,
                  height: 54,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(blurRadius: 6, color: Colors.black26)
                      ],
                    ),
                    child: const Icon(Icons.two_wheeler_rounded,
                        size: 28, color: Colors.white),
                  ),
                ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _liveChip() {
    return Obx(() {
      final upd = c.updatedAt.value;
      final hasRider = c.rider.value != null;
      final stale =
          upd != null && DateTime.now().difference(upd).inMinutes >= 2;
      final color = !hasRider
          ? Colors.grey
          : (stale ? AppColors.primaryOrange : AppColors.primaryGreen);
      final text = !hasRider
          ? 'लोकेशन शोधत आहे...'
          : (stale
              ? 'लोकेशन जुने आहे • ${_hhmm(upd)}'
              : (upd == null ? 'लाईव्ह' : 'लाईव्ह • ${_hhmm(upd)}'));

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(text, style: AppTextStyles.caption),
          ],
        ),
      );
    });
  }

  Widget _steps(int current) {
    const labels = ['तयारी सुरू', 'वाटेत आहे', 'पोहोचले'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= current
                        ? AppColors.primaryGreen
                        : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                      fontWeight:
                          i == current ? FontWeight.w700 : FontWeight.w400),
                ),
              ],
            ),
          ),
          if (i < labels.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _riderRow(String name, String mobile, String area) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final riderDetails = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name.isEmpty ? 'डिलिव्हरी बॉय' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardTitle,
            ),
            Text(
              area.isEmpty ? 'तुमची ऑर्डर घेऊन येत आहे' : 'सध्या: $area',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ],
        );

        final callButton = mobile.isEmpty
            ? null
            : InkWell(
                onTap: () => _call(mobile),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_rounded, color: Colors.white),
                ),
              );

        const avatar = CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryGreen,
          child: Icon(Icons.person_rounded, color: Colors.white),
        );

        if (constraints.maxWidth < 200) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(height: 8),
              riderDetails,
              if (callButton != null) ...[
                const SizedBox(height: 8),
                callButton,
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            avatar,
            const SizedBox(width: 12),
            Expanded(child: riderDetails),
            if (callButton != null) ...[
              const SizedBox(width: 8),
              callButton,
            ],
          ],
        );
      },
    );
  }

  Widget _addressRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final address = Text(
          widget.dropAddress,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body,
        );

        if (constraints.maxWidth < 160) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.home_rounded, color: AppColors.primaryOrange),
              const SizedBox(height: 6),
              address,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.home_rounded, color: AppColors.primaryOrange),
            const SizedBox(width: 10),
            Expanded(child: address),
          ],
        );
      },
    );
  }

  Widget _bottomCard() {
    return Obx(() {
      // read every observable HERE so GetX tracks them
      final step = _step(c.status.value);
      final eta = c.etaMinutes.value;
      final km = c.distanceKm.value;
      final hasRider = c.rider.value != null;
      final loaded = c.loaded.value;
      final name = c.riderName.value;
      final mobile = c.riderMobile.value;
      final area = c.areaName.value;

      String headline;
      if (step == 2) {
        headline = 'ऑर्डर पोहोचली 🎉';
      } else if (!hasRider) {
        headline = loaded
            ? 'डिलिव्हरी बॉयचे लोकेशन अजून उपलब्ध नाही'
            : 'लोड होत आहे...';
      } else if (eta != null) {
        headline = 'साधारण $eta मिनिटांत पोहोचेल';
      } else {
        headline = 'डिलिव्हरी बॉय वाटेत आहे';
      }

      final bottomInset = MediaQuery.of(context).padding.bottom;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(18, 16, 18, 20 + bottomInset),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [BoxShadow(blurRadius: 14, color: Colors.black26)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(headline, style: AppTextStyles.subHeading),
            if (km != null && step != 2)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('${km.toStringAsFixed(1)} किमी दूर',
                    style: AppTextStyles.caption),
              ),
            const SizedBox(height: 14),
            _steps(step),
            const Divider(height: 28),
            _riderRow(name, mobile, area),
            if (widget.dropAddress.isNotEmpty) ...[
              const Divider(height: 28),
              _addressRow(),
            ],
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[SCREEN] OrderTrackingScreen build, tileUA=$kTileUserAgent');
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECEF),
      body: Stack(
        children: [
          Positioned.fill(child: _mapView()),

          // top bar: back button + live status
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.black87),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _liveChip(),
                ],
              ),
            ),
          ),

          // shown only if map tiles keep failing
          if (_tileBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 70, 14, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'नकाशा लोड होत नाही. इंटरनेट तपासा.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),

          // map buttons + bottom card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 14, bottom: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'follow_${widget.orderId}',
                        backgroundColor:
                            _follow ? AppColors.primaryGreen : Colors.white,
                        onPressed: () {
                          setState(() => _follow = !_follow);
                          if (_follow && _shown != null && _mapReady) {
                            _map.move(_shown!, 16);
                          }
                        },
                        child: Icon(Icons.navigation_rounded,
                            color: _follow
                                ? Colors.white
                                : AppColors.primaryGreen),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton.small(
                        heroTag: 'recenter_${widget.orderId}',
                        backgroundColor: Colors.white,
                        onPressed: () {
                          setState(() => _follow = false);
                          _fit(force: true);
                        },
                        child: const Icon(Icons.my_location_rounded,
                            color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ),
                _bottomCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Light grid drawn behind the map so the area is never plain white/empty.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8ECEF);
    canvas.drawRect(Offset.zero & size, bg);
    final line = Paint()
      ..color = const Color(0xFFD2D8DD)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
