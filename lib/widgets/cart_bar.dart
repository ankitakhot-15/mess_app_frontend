import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/responsive.dart';

class CartBar extends StatelessWidget {
  final int count;
  final num total;
  final VoidCallback onTap;

  const CartBar({super.key, required this.count, required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(Responsive.w(12)),
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(18), vertical: Responsive.w(14)),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(Responsive.w(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_bag_rounded, color: AppColors.white),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Text('$count आयटम  |  ₹$total', style: AppTextStyles.button),
              ),
              Text('चेकआउट', style: AppTextStyles.button),
              const Icon(Icons.chevron_right_rounded, color: AppColors.white),
            ],
          ),
        ),
      ),
    );
  }
}
