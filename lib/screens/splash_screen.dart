import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/responsive.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      // logged in -> that role's dashboard, otherwise login
      Get.offAllNamed(AuthService.startRoute());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final logoSize = Responsive.isMobile ? Responsive.wp(75) : 340.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: AppLogo(size: logoSize),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: Responsive.w(24),
                width: Responsive.w(24),
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryOrange,
                ),
              ),
              SizedBox(height: Responsive.w(16)),
              Text('घरच्या चवीसारखं... प्रेमाने!',
                  style: AppTextStyles.tagline),
              SizedBox(height: Responsive.w(32)),
            ],
          ),
        ),
      ),
    );
  }
}
