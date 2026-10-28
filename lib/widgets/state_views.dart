import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/responsive.dart';
import 'common_button.dart';
import 'panel.dart';

/// API failure message + error code + retry button.
class ErrorView extends StatelessWidget {
  final String message;
  final int? code;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, this.code, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: EdgeInsets.all(Responsive.w(20)),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: Responsive.w(48), color: AppColors.error),
          SizedBox(height: Responsive.w(8)),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.body),
          if (code != null) ...[
            SizedBox(height: Responsive.w(4)),
            Text('Error code: $code', style: AppTextStyles.caption),
          ],
          SizedBox(height: Responsive.w(14)),
          CommonButton(text: 'पुन्हा प्रयत्न करा', icon: Icons.refresh_rounded, onPressed: onRetry),
        ],
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String emoji;
  final String text;
  const EmptyView({super.key, this.emoji = '🍽️', required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(28)),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: Responsive.sp(48))),
          SizedBox(height: Responsive.w(6)),
          Text(text, textAlign: TextAlign.center, style: AppTextStyles.bodyGrey),
        ],
      ),
    );
  }
}
