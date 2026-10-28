import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'panel.dart';

class LiveLocation {
  final double lat;
  final double lng;
  final String areaName;
  final DateTime? updatedAt;
  const LiveLocation({
    required this.lat,
    required this.lng,
    required this.areaName,
    this.updatedAt,
  });
}

/// Shows the delivery boy's live location and refreshes it automatically.
/// [fetch] must return the latest location from your tracking API.
class LiveLocationCard extends StatefulWidget {
  final Future<LiveLocation?> Function() fetch;
  final Duration interval;

  const LiveLocationCard({
    super.key,
    required this.fetch,
    this.interval = const Duration(seconds: 15),
  });

  @override
  State<LiveLocationCard> createState() => _LiveLocationCardState();
}

class _LiveLocationCardState extends State<LiveLocationCard> {
  Timer? _timer;
  LiveLocation? _loc;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(widget.interval, (_) => _refresh());
  }

  Future<void> _refresh() async {
    try {
      final data = await widget.fetch();
      if (!mounted) return;
      setState(() {
        if (data != null) _loc = data;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _ago(DateTime? t) {
    if (t == null) return '';
    final s = DateTime.now().difference(t.toLocal()).inSeconds;
    if (s < 60) return 'आत्ताच अपडेट';
    if (s < 3600) return '${s ~/ 60} मिनिटांपूर्वी';
    return '${s ~/ 3600} तासांपूर्वी';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Row(
        children: [
          const Icon(Icons.my_location_rounded, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('डिलिव्हरी बॉयचे सध्याचे लोकेशन', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                if (_loading)
                  const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                else
                  Text(
                    _loc == null ? 'लोकेशन उपलब्ध नाही' : _loc!.areaName,
                    style: AppTextStyles.cardTitle,
                  ),
                if (_loc != null)
                  Text(_ago(_loc!.updatedAt), style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}