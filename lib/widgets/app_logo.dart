import 'package:flutter/material.dart';

/// Common logo widget so the logo can be reused anywhere.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
