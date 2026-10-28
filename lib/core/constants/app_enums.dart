import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Roles returned by the backend (`user.role`).
enum UserRole {
  admin('ADMIN'),
  mavshi('MAVSHI'),
  delivery('DELIVERY'),
  customer('CUSTOMER');

  final String value;
  const UserRole(this.value);

  static UserRole? parse(String? v) {
    final s = (v ?? '').trim().toUpperCase();
    for (final r in values) {
      if (r.value == s) return r;
    }
    return null;
  }
}

/// Customer subscription plan.
enum OrderPlan {
  day('DAY', 'एक दिवस', 1),
  week('WEEK', 'आठवडा', 7),
  month('MONTH', 'महिना', 30);

  final String value;
  final String label;
  final int days;
  const OrderPlan(this.value, this.label, this.days);
}

enum PaymentMethod {
  online('ONLINE', 'ऑनलाइन पेमेंट'),
  cod('COD', 'कॅश ऑन डिलिव्हरी');

  final String value;
  final String label;
  const PaymentMethod(this.value, this.label);
}

/// Allowed values of `mealType` / `foodType` (menu items).
class MealTypes {
  MealTypes._();
  static const values = ['BREAKFAST', 'LUNCH', 'DINNER', 'FULL_DAY'];
  static String label(String v) {
    switch (v) {
      case 'BREAKFAST':
        return 'नाश्ता';
      case 'LUNCH':
        return 'दुपारचे जेवण';
      case 'DINNER':
        return 'रात्रीचे जेवण';
      case 'FULL_DAY':
        return 'पूर्ण दिवस';
      default:
        return v;
    }
  }
}

class FoodTypes {
  FoodTypes._();
  static const values = ['VEG', 'NON_VEG', 'BOTH'];
  static String label(String v) {
    switch (v) {
      case 'VEG':
        return 'शाकाहारी';
      case 'NON_VEG':
        return 'मांसाहारी';
      case 'BOTH':
        return 'शाकाहारी + मांसाहारी';
      default:
        return v;
    }
  }
}

/// Order status values + Marathi labels + colours (shared by all roles).
class OrderStatus {
  OrderStatus._();

  static const paymentPending = 'PAYMENT_PENDING';
  static const placed = 'PLACED';
  static const accepted = 'ACCEPTED';
  static const rejected = 'REJECTED';
  static const cancelled = 'CANCELLED';
  static const preparing = 'PREPARING';
  static const ready = 'READY';
  static const outForDelivery = 'OUT_FOR_DELIVERY';
  static const delivered = 'DELIVERED';

  /// Statuses for which the customer can see tracking.
  static const trackable = {accepted, preparing, ready, outForDelivery, delivered};

  static String label(String s) {
    switch (s) {
      case paymentPending:
        return 'पेमेंट बाकी';
      case placed:
        return 'ऑर्डर दिली';
      case accepted:
        return 'स्वीकारली';
      case rejected:
        return 'नाकारली';
      case cancelled:
        return 'रद्द केली';
      case preparing:
        return 'तयारी सुरू';
      case ready:
        return 'तयार आहे';
      case outForDelivery:
        return 'डिलिव्हरीसाठी निघाली';
      case delivered:
        return 'पोहोचली';
      default:
        return s;
    }
  }

  static Color color(String s) {
    switch (s) {
      case delivered:
        return AppColors.primaryGreen;
      case rejected:
      case cancelled:
        return AppColors.error;
      case paymentPending:
      case placed:
        return AppColors.grey;
      default:
        return AppColors.primaryOrange;
    }
  }
}
