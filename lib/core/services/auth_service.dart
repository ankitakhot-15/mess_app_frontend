import 'package:get/get.dart';
import '../../app/app_routes.dart';
import '../../model/user_model.dart';
import '../constants/app_enums.dart';
import '../utils/app_logger.dart';
import '../utils/storage_service.dart';

/// Role based navigation + logout. The ONLY place that knows
/// "which role goes to which home screen".
class AuthService {
  AuthService._();

  static UserModel? get currentUser => StorageService.user;
  static UserRole? get currentRole => StorageService.user?.role;

  /// Home route for a role. `null` = this app has no screen for the role (ADMIN).
  static String? homeRouteFor(UserRole? role) {
    switch (role) {
      case UserRole.customer:
        return AppRoutes.customerHome;
      case UserRole.mavshi:
        return AppRoutes.mavshiHome;
      case UserRole.delivery:
        return AppRoutes.deliveryHome;
      case UserRole.admin:
      case null:
        return null;
    }
  }

  /// Route to open right after login / app start.
  static String startRoute() {
    if (!StorageService.isLoggedIn) return AppRoutes.login;
    return homeRouteFor(currentRole) ?? AppRoutes.login;
  }

  /// Go to the correct dashboard for the logged-in user.
  static void goHome() => Get.offAllNamed(startRoute());

  static Future<void> logout() async {
    AppLogger.i('User logged out', tag: 'AUTH');
    await StorageService.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
