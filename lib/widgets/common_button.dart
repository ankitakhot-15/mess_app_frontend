import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/responsive.dart';

/// Common button – filled (green) or outlined (orange) with loading state.
class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primaryGreen;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Responsive.w(14)),
    );

    final child = isLoading
        ? SizedBox(
            height: Responsive.w(22),
            width: Responsive.w(22),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isOutlined ? AppColors.primaryOrange : AppColors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: Responsive.w(20)),
                SizedBox(width: Responsive.w(8)),
              ],
              Text(
                text,
                style: isOutlined
                    ? AppTextStyles.button
                        .copyWith(color: AppColors.primaryOrange)
                    : AppTextStyles.button,
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: Responsive.w(52),
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryOrange,
                side: const BorderSide(
                    color: AppColors.primaryOrange, width: 1.5),
                shape: shape,
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: AppColors.white,
                elevation: 3,
                shadowColor: bg.withOpacity(0.4),
                shape: shape,
              ),
              child: child,
            ),
    );
  }
}
