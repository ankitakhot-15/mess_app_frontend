import 'package:flutter/material.dart';
import '../core/app_text_styles.dart';
import '../core/constants/app_enums.dart';
import '../core/responsive.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = OrderStatus.color(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.w(4)),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Responsive.w(20)),
      ),
      child: Text(OrderStatus.label(status),
          style: AppTextStyles.caption.copyWith(color: c, fontWeight: FontWeight.w700)),
    );
  }
}
