import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';

/// White rounded card used everywhere.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const Panel({super.key, required this.child, this.padding, this.margin, this.onTap});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      margin: margin,
      padding: padding ?? EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(18)),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: box);
  }
}
