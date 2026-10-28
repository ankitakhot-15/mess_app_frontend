import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_enums.dart';
import '../core/services/auth_service.dart';
import '../core/utils/storage_service.dart';
import 'app_routes.dart';

/// Role based route guard.
///  - not logged in            -> login
///  - logged in with OTHER role -> that role's own home
class RoleMiddleware extends GetMiddleware {
  final UserRole role;
  RoleMiddleware(this.role);

  @override
  RouteSettings? redirect(String? route) {
    if (!StorageService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    final current = AuthService.currentRole;
    if (current != role) {
      return RouteSettings(name: AuthService.homeRouteFor(current) ?? AppRoutes.login);
    }
    return null;
  }
}

/// Any logged-in user (any role).
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      StorageService.isLoggedIn ? null : const RouteSettings(name: AppRoutes.login);
}
