import 'package:get/get.dart';
import '../controllers/customer/cart_controller.dart';
import '../controllers/customer/checkout_controller.dart';
import '../controllers/customer/customer_home_controller.dart';
import '../controllers/customer/customer_orders_controller.dart';
import '../controllers/customer/customer_profile_controller.dart';
import '../controllers/customer/customer_shell_controller.dart';
import '../controllers/customer/mess_detail_controller.dart';
import '../controllers/customer/order_detail_controller.dart';
import '../controllers/delivery/delivery_home_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/mavshi/mavshi_home_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/register_controller.dart';
import '../core/constants/app_enums.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/customer_shell_screen.dart';
import '../screens/customer/mess_detail_screen.dart';
import '../screens/customer/order_detail_screen.dart';
import '../screens/delivery/delivery_home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/mavshi/mavshi_home_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import 'app_routes.dart';
import 'role_middleware.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() => Get.lazyPut<LoginController>(() => LoginController())),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(
          () => Get.lazyPut<RegisterController>(() => RegisterController())),
    ),

    // ---------------- CUSTOMER ----------------
    GetPage(
      name: AppRoutes.customerHome,
      page: () => const CustomerShellScreen(),
      middlewares: [RoleMiddleware(UserRole.customer)],
      binding: BindingsBuilder(() {
        // created together so every tab / checkout can share the cart
        Get.put<CartController>(CartController());
        Get.put<CustomerShellController>(CustomerShellController());
        Get.put<CustomerHomeController>(CustomerHomeController());
        Get.put<CustomerOrdersController>(CustomerOrdersController());
        Get.put<CustomerProfileController>(CustomerProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.messDetail,
      page: () => const MessDetailScreen(),
      middlewares: [RoleMiddleware(UserRole.customer)],
      binding: BindingsBuilder(
          () => Get.lazyPut<MessDetailController>(() => MessDetailController())),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutScreen(),
      middlewares: [RoleMiddleware(UserRole.customer)],
      binding: BindingsBuilder(
          () => Get.lazyPut<CheckoutController>(() => CheckoutController())),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailScreen(),
      middlewares: [RoleMiddleware(UserRole.customer)],
      binding: BindingsBuilder(
          () => Get.lazyPut<OrderDetailController>(() => OrderDetailController())),
    ),

    // ---------------- MAVSHI (mess owner) ----------------
    GetPage(
      name: AppRoutes.mavshiHome,
      page: () => const MavshiHomeScreen(),
      middlewares: [RoleMiddleware(UserRole.mavshi)],
      binding: BindingsBuilder(
          () => Get.lazyPut<MavshiHomeController>(() => MavshiHomeController())),
    ),

    // ---------------- DELIVERY BOY ----------------
    GetPage(
      name: AppRoutes.deliveryHome,
      page: () => const DeliveryHomeScreen(),
      middlewares: [RoleMiddleware(UserRole.delivery)],
      binding: BindingsBuilder(
          () => Get.lazyPut<DeliveryHomeController>(() => DeliveryHomeController())),
    ),

    // ---------------- COMMON ----------------
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(
          () => Get.lazyPut<NotificationController>(() => NotificationController())),
    ),
  ];
}
