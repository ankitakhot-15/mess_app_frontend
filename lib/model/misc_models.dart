import '../core/utils/json_helper.dart';

/// Pincode + area that has an approved mess (`GET /public/service-areas`).
class ServiceArea {
  final String pincode;
  final String areaName;
  const ServiceArea(this.pincode, this.areaName);

  static List<ServiceArea> parseList(dynamic data) {
    final raw = data is Map ? (data['areas'] ?? data['serviceAreas'] ?? data['items']) : data;
    final out = <ServiceArea>[];
    final seen = <String>{};
    if (raw is List) {
      for (final e in raw) {
        ServiceArea? a;
        if (e is Map) {
          final m = J.map(e);
          a = ServiceArea(J.str(m['pincode']), J.firstStr(m, ['areaName', 'area', 'name']));
        } else if (e != null) {
          a = ServiceArea(e.toString(), '');
        }
        if (a != null && a.pincode.isNotEmpty && seen.add('${a.pincode}|${a.areaName}')) {
          out.add(a);
        }
      }
    }
    return out;
  }
}

/// `GET /mavshi/status`
class MavshiStatus {
  final String status; // PENDING | ACTIVE | REJECTED | BLOCKED
  final String rejectionReason;
  final String planName;

  const MavshiStatus({required this.status, required this.rejectionReason, required this.planName});

  bool get isActive => status == 'ACTIVE';
  bool get isPending => status == 'PENDING';
  bool get isRejected => status == 'REJECTED';

  factory MavshiStatus.fromJson(Map<String, dynamic> j) {
    final plan = j['plan'];
    return MavshiStatus(
      status: J.str(j['status'], 'PENDING'),
      rejectionReason: J.firstStr(j, ['rejectionReason', 'reason']),
      planName: plan is Map ? J.firstStr(J.map(plan), ['name']) : J.str(j['planName'] ?? plan),
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
      id: id, title: title, message: message, isRead: isRead ?? this.isRead, createdAt: createdAt);

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
        id: J.id(j),
        title: J.str(j['title']),
        message: J.firstStr(j, ['message', 'body']),
        isRead: J.boolean(j['isRead'] ?? j['read']),
        createdAt: J.str(j['createdAt']),
      );
}
