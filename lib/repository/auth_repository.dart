import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/api_service.dart';
import '../core/utils/json_helper.dart';
import '../model/auth_data.dart';
import '../model/misc_models.dart';

/// Login / register / public – none of these need a token.
class AuthRepository {
  final ApiService _api;
  AuthRepository(this._api);

  Future<ApiResponse<AuthData>> login({required String mobile, required String password}) =>
      _api.post<AuthData>(
        ApiConstants.login,
        requiresAuth: false,
        body: {'mobile': mobile, 'password': password},
        parser: (d) => AuthData.fromJson(J.map(d)),
      );

  Future<ApiResponse<AuthData>> registerCustomer({
    required String fullName,
    required String mobile,
    required String password,
    required String email,
    required String address,
    required String areaName,
    required String pincode,
  }) =>
      _api.post<AuthData>(
        ApiConstants.registerCustomer,
        requiresAuth: false,
        body: {
          'fullName': fullName,
          'mobile': mobile,
          'password': password,
          if (email.isNotEmpty) 'email': email,
          'address': address,
          'areaName': areaName,
          'pincode': pincode,
        },
        parser: (d) => AuthData.fromJson(J.map(d)),
      );

  Future<ApiResponse<AuthData>> registerDelivery({
    required String fullName,
    required String mobile,
    required String password,
    required String address,
    required String areaName,
    required String pincode,
    required String vehicleType, // BIKE | SCOOTER | CYCLE
    required String vehicleNumber,
    required String licenseNumber,
  }) =>
      _api.post<AuthData>(
        ApiConstants.registerDelivery,
        requiresAuth: false,
        body: {
          'fullName': fullName,
          'mobile': mobile,
          'password': password,
          'address': address,
          'areaName': areaName,
          'pincode': pincode,
          'vehicleType': vehicleType,
          if (vehicleNumber.isNotEmpty) 'vehicleNumber': vehicleNumber,
          if (licenseNumber.isNotEmpty) 'licenseNumber': licenseNumber,
        },
        parser: (d) => AuthData.fromJson(J.map(d)),
      );

  Future<ApiResponse<AuthData>> registerMavshi({
    required Map<String, dynamic> body,
  }) =>
      _api.post<AuthData>(
        ApiConstants.registerMavshi,
        requiresAuth: false,
        body: body,
        parser: (d) => AuthData.fromJson(J.map(d)),
      );

  Future<ApiResponse<List<ServiceArea>>> serviceAreas() => _api.get<List<ServiceArea>>(
        ApiConstants.serviceAreas,
        requiresAuth: false,
        parser: ServiceArea.parseList,
      );
}
