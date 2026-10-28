import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/responsive.dart';
import '../core/utils/date_helper.dart';
import '../widgets/app_loader.dart';
import '../widgets/panel.dart';
import '../widgets/state_views.dart';

/// In-app notifications – shared by customer, mavshi and delivery boy.
class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('सूचना', style: AppTextStyles.subHeading.copyWith(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: Text('सर्व वाचले',
                style: AppTextStyles.label.copyWith(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: controller.load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(Responsive.w(16)),
                  children: [
                    Obx(() {
                      if (controller.isLoading.value) return const LoaderView();
                      if (controller.errorMessage.value != null) {
                        return ErrorView(
                            message: controller.errorMessage.value!,
                            code: controller.errorCode.value,
                            onRetry: controller.load);
                      }
                      if (controller.items.isEmpty) {
                        return const EmptyView(emoji: '🔔', text: 'सूचना नाहीत');
                      }
                      return Column(
                        children: controller.items
                            .map((n) => Panel(
                                  margin: EdgeInsets.only(bottom: Responsive.w(10)),
                                  onTap: () => controller.markRead(n),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.circle,
                                          size: Responsive.w(10),
                                          color: n.isRead
                                              ? Colors.transparent
                                              : AppColors.primaryOrange),
                                      SizedBox(width: Responsive.w(8)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (n.title.isNotEmpty)
                                              Text(n.title,
                                                  style: AppTextStyles.cardTitle.copyWith(
                                                      fontWeight: n.isRead
                                                          ? FontWeight.w500
                                                          : FontWeight.w800)),
                                            if (n.message.isNotEmpty)
                                              Text(n.message, style: AppTextStyles.body),
                                            if (n.createdAt.isNotEmpty)
                                              Text(DateHelper.fromApi(n.createdAt),
                                                  style: AppTextStyles.caption),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
