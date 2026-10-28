import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/app_routes.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../controllers/customer/mess_detail_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants/app_enums.dart';
import '../../core/responsive.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/cart_bar.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/panel.dart';
import '../../widgets/state_views.dart';

/// Mess info + menu with plan selector (DAY / WEEK / MONTH).
class MessDetailScreen extends GetView<MessDetailController> {
  const MessDetailScreen({super.key});

  CartController get cart => Get.find<CartController>();

  Widget _header() => Obx(() {
        final m = controller.header;
        return Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.messName, style: AppTextStyles.subHeading),
              if (m.ownerName.isNotEmpty)
                Text('मावशी: ${m.ownerName}', style: AppTextStyles.bodyGrey),
              Text([m.address, m.areaName, m.pincode].where((s) => s.isNotEmpty).join(', '),
                  style: AppTextStyles.caption),
              if (m.experienceYears > 0)
                Text('${m.experienceYears} वर्षांचा अनुभव', style: AppTextStyles.caption),
            ],
          ),
        );
      });

  Widget _planSelector() => Obx(() => Row(
        children: OrderPlan.values.map((p) {
          final selected = cart.plan.value == p;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: p == OrderPlan.month ? 0 : Responsive.w(8)),
              child: GestureDetector(
                onTap: () => cart.plan.value = p,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: Responsive.w(12)),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryGreen : AppColors.white,
                    borderRadius: BorderRadius.circular(Responsive.w(14)),
                    border: Border.all(
                        color: selected ? AppColors.primaryGreen : AppColors.lightGrey),
                  ),
                  child: Column(
                    children: [
                      Text(p.label,
                          style: AppTextStyles.cardTitle.copyWith(
                              color: selected ? AppColors.white : AppColors.brown)),
                      Text('${p.days} दिवस',
                          style: AppTextStyles.caption.copyWith(
                              color: selected ? AppColors.cream : AppColors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ));

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(controller.mess.messName,
            style: AppTextStyles.subHeading.copyWith(color: Colors.white)),
      ),
      bottomNavigationBar: Obx(() => cart.isEmpty
          ? const SizedBox.shrink()
          : CartBar(
              count: cart.count,
              total: cart.subtotal,
              onTap: () => Get.toNamed(AppRoutes.checkout),
            )),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(Responsive.w(16)),
              children: [
                _header(),
                SizedBox(height: Responsive.w(16)),
                Text('प्लॅन निवडा', style: AppTextStyles.subHeading),
                SizedBox(height: Responsive.w(8)),
                _planSelector(),
                SizedBox(height: Responsive.w(6)),
                Text('मेनूच्या किंमतीत डिलिव्हरी चार्ज समाविष्ट नाही. तो चेकआउटला वेगळा दिसेल.',
                    style: AppTextStyles.caption),
                SizedBox(height: Responsive.w(16)),
                Text('मेनू', style: AppTextStyles.subHeading),
                SizedBox(height: Responsive.w(10)),
                Obx(() {
                  if (controller.isLoading.value) return const LoaderView();
                  if (controller.errorMessage.value != null) {
                    return ErrorView(
                        message: controller.errorMessage.value!,
                        code: controller.errorCode.value,
                        onRetry: controller.load);
                  }
                  if (controller.items.isEmpty) {
                    return const EmptyView(text: 'मेनू अजून उपलब्ध नाही');
                  }
                  return Column(
                    children: controller.items
                        .map((i) => Padding(
                              padding: EdgeInsets.only(bottom: Responsive.w(12)),
                              child: MenuCard(
                                item: i,
                                plan: cart.plan.value,
                                quantity: cart.qty(i.id),
                                onAdd: () => cart.add(controller.mess, i),
                                onRemove: () => cart.remove(i.id),
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
    );
  }
}
