/// All API related constants in one place.
class ApiConstants {
  ApiConstants._();

  // static const String baseUrl = 'http://10.0.2.2:5000/api/v1';
  // static const String baseUrl = 'http://192.168.1.7:5000/api/v1';
  static const String baseUrl = 'http://192.168.1.7:5000/api/v1';
  static const Duration timeout = Duration(seconds: 20);

  // ---------- auth & public (no token) ----------
  static const String login = '/auth/login';
  static const String registerCustomer = '/auth/register/customer';
  static const String registerDelivery = '/auth/register/delivery';
  static const String registerMavshi = '/auth/register/mavshi';
  static const String serviceAreas = '/public/service-areas';

  // ---------- common (any logged-in user) ----------
  static const String me = '/users/me';
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // ---------- customer ----------
  static const String customerProfile = '/customer/profile';
  static const String customerMesses = '/customer/messes';
  static String customerMess(String id) => '/customer/messes/$id';
  static const String orderPreview = '/customer/orders/preview';
  static const String customerOrders = '/customer/orders';
  static String customerOrder(String id) => '/customer/orders/$id';
  static String customerTracking(String id) => '/customer/orders/$id/tracking';
  
  static String customerCancel(String id) => '/customer/orders/$id/cancel';
  static const String paymentVerify = '/payments/verify';

  // ---------- mavshi ----------
  static const String mavshiStatus = '/mavshi/status';
  static const String mavshiProfile = '/mavshi/profile';
  static const String mavshiMenu = '/mavshi/menu';
  static String mavshiMenuItem(String id) => '/mavshi/menu/$id';
  static const String mavshiOrders = '/mavshi/orders';
  static String mavshiOrderStatus(String id) => '/mavshi/orders/$id/status';

  // ---------- delivery ----------
  static const String deliveryOrders = '/delivery/orders';
  static String deliveryOrder(String id) => '/delivery/orders/$id';
  static String deliveryPickup(String id) => '/delivery/orders/$id/pickup';
  static String deliveryDeliver(String id) => '/delivery/orders/$id/deliver';
  static String deliveryTraffic(String id) => '/delivery/orders/$id/traffic';
  static const String deliveryLocation = '/delivery/location';
  static const String deliveryAvailability = '/delivery/availability';
}

/// Error codes used by the app itself (HTTP codes are used as-is).
class ApiCode {
  ApiCode._();

  static const int noInternet = -1;
  static const int timeout = -2;
  static const int parseError = -3;
  static const int unknown = -4;
}
