import '../core/utils/json_helper.dart';

class TimelineEntry {
  final String status;
  final String time;
  final String note;
  const TimelineEntry({required this.status, required this.time, required this.note});

  factory TimelineEntry.fromJson(Map<String, dynamic> j) => TimelineEntry(
        status: J.str(j['status']),
        time: J.firstStr(j, ['at', 'time', 'createdAt', 'timestamp']),
        note: J.firstStr(j, ['note', 'message']),
      );
}

/// `GET /customer/orders/:id/tracking`
class TrackingModel {
  final String message; // e.g. "delivered in about 25 min" / traffic delay
  final String deliveryBoyName;
  final String deliveryBoyMobile;
  final String areaName;
  final List<TimelineEntry> timeline;

  const TrackingModel({
    required this.message,
    required this.deliveryBoyName,
    required this.deliveryBoyMobile,
    required this.areaName,
    required this.timeline,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> j) {
    final boy = J.map(j['deliveryBoy']);
    final loc = J.map(j['location']);
    return TrackingModel(
      message: J.firstStr(j, ['etaMessage', 'message', 'eta']),
      deliveryBoyName: J.firstStr(boy, ['fullName', 'name']),
      deliveryBoyMobile: J.firstStr(boy, ['mobile']),
      areaName: J.firstStr(j, ['areaName', 'currentArea'], J.firstStr(loc, ['areaName'])),
      timeline: J.list(j['timeline']).map(TimelineEntry.fromJson).toList(),
    );
  }
}
