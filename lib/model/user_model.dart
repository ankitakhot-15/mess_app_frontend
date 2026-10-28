import '../core/constants/app_enums.dart';
import '../core/utils/json_helper.dart';

class UserModel {
  final String id;
  final String fullName;
  final String mobile;
  final String email;
  final String address;
  final String areaName;
  final String pincode;
  final String roleValue; // raw: ADMIN | MAVSHI | DELIVERY | CUSTOMER
  final String status; // ACTIVE | PENDING | REJECTED | BLOCKED
  final String messName; // only for mavshi
  final bool isAvailable; // only for delivery boy (on / off duty)

  const UserModel({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.address,
    required this.areaName,
    required this.pincode,
    required this.roleValue,
    required this.status,
    required this.messName,
    this.isAvailable = false,
  });

  UserRole? get role => UserRole.parse(roleValue);

  UserModel copyWith({
    String? fullName,
    String? email,
    String? address,
    String? areaName,
    String? pincode,
    bool? isAvailable,
  }) =>
      UserModel(
        id: id,
        fullName: fullName ?? this.fullName,
        mobile: mobile,
        email: email ?? this.email,
        address: address ?? this.address,
        areaName: areaName ?? this.areaName,
        pincode: pincode ?? this.pincode,
        roleValue: roleValue,
        status: status,
        messName: messName,
        isAvailable: isAvailable ?? this.isAvailable,
      );

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: J.id(j),
        fullName: J.str(j['fullName']),
        mobile: J.str(j['mobile']),
        email: J.str(j['email']),
        address: J.str(j['address']),
        areaName: J.str(j['areaName']),
        pincode: J.str(j['pincode']),
        roleValue: J.str(j['role']),
        status: J.str(j['status']),
        messName: J.str(j['messName']),
        isAvailable: J.boolean(j['isAvailable']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'mobile': mobile,
        'email': email,
        'address': address,
        'areaName': areaName,
        'pincode': pincode,
        'role': roleValue,
        'status': status,
        'messName': messName,
        'isAvailable': isAvailable,
      };
}
