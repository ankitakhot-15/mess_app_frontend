import '../core/utils/json_helper.dart';
import 'menu_item.dart';

/// A mess (mavshi) shown to the customer.
class MessModel {
  /// Mavshi id – used in `/customer/messes/:id` and as `mavshiId` when ordering.
  final String id;
  final String messName;
  final String ownerName;
  final String areaName;
  final String pincode;
  final String address;
  final int experienceYears;

  const MessModel({
    required this.id,
    required this.messName,
    required this.ownerName,
    required this.areaName,
    required this.pincode,
    required this.address,
    required this.experienceYears,
  });

  factory MessModel.fromJson(Map<String, dynamic> j) => MessModel(
        id: J.str(j['mavshiId'] ?? j['id'] ?? j['_id']),
        messName: J.firstStr(j, ['messName', 'name'], 'मेस'),
        ownerName: J.firstStr(j, ['fullName', 'ownerName']),
        areaName: J.str(j['areaName']),
        pincode: J.str(j['pincode']),
        address: J.str(j['address']),
        experienceYears: J.integer(j['cookingExperienceYears']),
      );
}

/// `GET /customer/messes/:id` – mess + menu.
class MessDetail {
  final MessModel mess;
  final List<MenuItem> menu;

  const MessDetail({required this.mess, required this.menu});

  factory MessDetail.fromJson(Map<String, dynamic> j) {
    final messMap = j['mess'] is Map ? J.map(j['mess']) : (j['mavshi'] is Map ? J.map(j['mavshi']) : j);
    final menuRaw = j['menu'] ?? j['items'] ?? j['menuItems'] ?? messMap['menu'] ?? messMap['items'];
    return MessDetail(
      mess: MessModel.fromJson(messMap),
      menu: J.list(menuRaw).map(MenuItem.fromJson).toList(),
    );
  }
}
