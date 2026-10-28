import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationHelper {
  /// Returns true only when device location is ON and permission is granted.
  /// Shows messages only when something is wrong.
  static Future<bool> ensureLocationOn() async {
    // 1. Device location (GPS) switch
    if (!await Geolocator.isLocationServiceEnabled()) {
      final open = await _confirm(
        title: 'लोकेशन चालू करा',
        message: 'ऑर्डर डिलिव्हरीसाठी कृपया तुमचे लोकेशन चालू करा.',
        okText: 'सेटिंग्ज उघडा',
      );
      if (open != true) {
        _toast('लोकेशन बंद आहे. कृपया चालू करा.');
        return false;
      }

      // Opens the device location settings screen directly
      await Geolocator.openLocationSettings();
      // Wait until the user comes back to the app
      await _waitForAppResume();
      // Give the system a moment to update the GPS status
      await Future.delayed(const Duration(milliseconds: 500));

      if (!await Geolocator.isLocationServiceEnabled()) {
        _toast('लोकेशन अजूनही बंद आहे. कृपया चालू करा.');
        return false;
      }
    }

    // 2. App permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      _toast('लोकेशन परवानगी नाकारली आहे.');
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      final open = await _confirm(
        title: 'परवानगी आवश्यक',
        message:
            'लोकेशन परवानगी कायमची बंद आहे. कृपया अ‍ॅप सेटिंग्जमधून चालू करा.',
        okText: 'अ‍ॅप सेटिंग्ज',
      );
      if (open == true) await Geolocator.openAppSettings();
      return false;
    }

    // 3. All good. No snackbar here, so it can't interfere with the loader.
    if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
    return true;
  }

  // ---- helpers ----

  static Future<void> _waitForAppResume() {
    final completer = Completer<void>();
    late final _ResumeObserver observer;
    observer = _ResumeObserver(() {
      WidgetsBinding.instance.removeObserver(observer);
      if (!completer.isCompleted) completer.complete();
    });
    WidgetsBinding.instance.addObserver(observer);
    // Safety timeout so we never hang forever
    return completer.future.timeout(const Duration(minutes: 2), onTimeout: () {
      WidgetsBinding.instance.removeObserver(observer);
    });
  }

  static Future<bool?> _confirm({
    required String title,
    required String message,
    required String okText,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('रद्द करा'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(okText),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Error messages only.
  static void _toast(String msg) {
    Get.snackbar(
      'लोकेशन',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }
}

class _ResumeObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  _ResumeObserver(this.onResume);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}
