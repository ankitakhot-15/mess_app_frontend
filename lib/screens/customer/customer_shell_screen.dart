import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/app_routes.dart';
import '../../controllers/customer/customer_home_controller.dart';
import '../../controllers/customer/customer_orders_controller.dart';
import '../../controllers/customer/customer_profile_controller.dart';
import '../../controllers/customer/customer_shell_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants/app_enums.dart';
import '../../core/responsive.dart';
import '../../core/utils/validators.dart';
import '../../model/mess_model.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_text_field.dart';
import '../../widgets/order_card.dart';
import '../../widgets/panel.dart';
import '../../widgets/state_views.dart';

/// CUSTOMER dashboard – bottom navigation: messes | my orders | profile.
class CustomerShellScreen extends GetView<CustomerShellController> {
  const CustomerShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Obx(() => IndexedStack(
                index: controller.tab.value,
                children: const [_MessesTab(), _OrdersTab(), _ProfileTab()],
              )),
        ),
      ),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.tab.value,
            backgroundColor: AppColors.white,
            indicatorColor: AppColors.primaryGreen.withOpacity(0.15),
            onDestinationSelected: (i) {
              controller.tab.value = i;
              if (i == 1) Get.find<CustomerOrdersController>().load();
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded),
                  label: 'मेस'),
              NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded),
                  label: 'ऑर्डर'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'प्रोफाइल'),
            ],
          )),
    );
  }
}

// =====================================================================
//  TAB 1 – messes in my area
// =====================================================================
class _MessesTab extends GetView<CustomerHomeController> {
  const _MessesTab();

  Widget _header() => Row(
        children: [
          AppLogo(size: Responsive.w(52)),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userName.isEmpty
                      ? 'नमस्कार 🙏'
                      : 'नमस्कार, ${controller.userName} 🙏',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subHeading,
                ),
                Text('तुमच्या भागातील मेस', style: AppTextStyles.bodyGrey),
              ],
            ),
          ),
          IconButton(
            tooltip: 'सूचना',
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.brown,
          ),
        ],
      );

  Widget _pincodeBar() => Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.pincodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: AppTextStyles.body,
              onSubmitted: (_) => controller.load(),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'पिनकोड',
                prefixIcon: const Icon(Icons.pin_drop_outlined, color: AppColors.primaryOrange),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: EdgeInsets.symmetric(vertical: Responsive.w(12)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.w(14)),
                    borderSide: const BorderSide(color: AppColors.lightGrey)),
              ),
            ),
          ),
          SizedBox(width: Responsive.w(10)),
          SizedBox(
            height: Responsive.w(48),
            child: ElevatedButton(
              onPressed: controller.load,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.w(14))),
              ),
              child: const Icon(Icons.search_rounded),
            ),
          ),
        ],
      );

  Widget _messCard(MessModel m) => Panel(
        margin: EdgeInsets.only(bottom: Responsive.w(12)),
        onTap: () => Get.toNamed(AppRoutes.messDetail, arguments: m),
        child: Row(
          children: [
            Container(
              width: Responsive.w(56),
              height: Responsive.w(56),
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
              child: Text('🍱', style: TextStyle(fontSize: Responsive.sp(28))),
            ),
            SizedBox(width: Responsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.messName, style: AppTextStyles.cardTitle),
                  if (m.ownerName.isNotEmpty)
                    Text('मावशी: ${m.ownerName}', style: AppTextStyles.caption),
                  Text(
                      [m.areaName, m.pincode].where((s) => s.isNotEmpty).join(' • '),
                      style: AppTextStyles.caption),
                  if (m.experienceYears > 0)
                    Text('${m.experienceYears} वर्षांचा अनुभव', style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.w(12)),
        children: [
          _header(),
          SizedBox(height: Responsive.w(14)),
          _pincodeBar(),
          SizedBox(height: Responsive.w(16)),
          Obx(() {
            if (controller.isLoading.value) return const LoaderView();
            if (controller.errorMessage.value != null) {
              return ErrorView(
                  message: controller.errorMessage.value!,
                  code: controller.errorCode.value,
                  onRetry: controller.load);
            }
            if (controller.messes.isEmpty) {
              return const EmptyView(text: 'या पिनकोडमध्ये अजून मेस उपलब्ध नाही');
            }
            return Column(children: controller.messes.map(_messCard).toList());
          }),
        ],
      ),
    );
  }
}

// =====================================================================
//  TAB 2 – my orders
// =====================================================================
class _OrdersTab extends GetView<CustomerOrdersController> {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.w(12)),
        children: [
          Text('माझ्या ऑर्डर', style: AppTextStyles.heading),
          SizedBox(height: Responsive.w(10)),
          SizedBox(
            height: Responsive.w(40),
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  children: CustomerOrdersController.filters
                      .map((f) => Padding(
                            padding: EdgeInsets.only(right: Responsive.w(8)),
                            child: ChoiceChip(
                              label: Text(f == null ? 'सर्व' : OrderStatus.label(f)),
                              selected: controller.filter.value == f,
                              selectedColor: AppColors.primaryGreen,
                              labelStyle: AppTextStyles.caption.copyWith(
                                  color: controller.filter.value == f
                                      ? Colors.white
                                      : AppColors.brown,
                                  fontWeight: FontWeight.w700),
                              onSelected: (_) => controller.setFilter(f),
                            ),
                          ))
                      .toList(),
                )),
          ),
          SizedBox(height: Responsive.w(12)),
          Obx(() {
            if (controller.isLoading.value) return const LoaderView();
            if (controller.errorMessage.value != null) {
              return ErrorView(
                  message: controller.errorMessage.value!,
                  code: controller.errorCode.value,
                  onRetry: controller.load);
            }
            if (controller.orders.isEmpty) {
              return const EmptyView(emoji: '🧾', text: 'ऑर्डर सापडल्या नाहीत');
            }
            return Column(
              children: controller.orders
                  .map((o) => OrderCard(
                        order: o,
                        showMess: true,
                        onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: o.id),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

// =====================================================================
//  TAB 3 – profile
// =====================================================================
class _ProfileTab extends GetView<CustomerProfileController> {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: Responsive.w(14));
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(20), vertical: Responsive.w(12)),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.contentWidth),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('माझी प्रोफाइल', style: AppTextStyles.heading),
                SizedBox(height: Responsive.w(4)),
                Text('मोबाईल: ${controller.mobile}', style: AppTextStyles.bodyGrey),
                SizedBox(height: Responsive.w(16)),
                CommonTextField(
                  label: 'पूर्ण नाव',
                  hint: 'पूर्ण नाव',
                  controller: controller.fullNameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => Validators.minLength(v, 'पूर्ण नाव', 2),
                ),
                gap,
                CommonTextField(
                  label: 'ईमेल (ऐच्छिक)',
                  hint: 'name@example.com',
                  controller: controller.emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.optionalEmail,
                ),
                gap,
                CommonTextField(
                  label: 'पत्ता',
                  hint: 'पत्ता',
                  controller: controller.addressController,
                  prefixIcon: Icons.home_outlined,
                  maxLines: 2,
                  validator: (v) => Validators.required(v, 'पत्ता'),
                ),
                gap,
                CommonTextField(
                  label: 'परिसर / एरिया',
                  hint: 'परिसर',
                  controller: controller.areaNameController,
                  prefixIcon: Icons.map_outlined,
                  validator: (v) => Validators.required(v, 'परिसर'),
                ),
                gap,
                CommonTextField(
                  label: 'पिनकोड',
                  hint: '४१६००१',
                  controller: controller.pincodeController,
                  prefixIcon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textInputAction: TextInputAction.done,
                  validator: Validators.pincode,
                ),
                SizedBox(height: Responsive.w(20)),
                CommonButton(
                    text: 'सेव्ह करा', icon: Icons.check_rounded, onPressed: controller.save),
                SizedBox(height: Responsive.w(12)),
                CommonButton(
                  text: 'लॉगआउट',
                  icon: Icons.logout_rounded,
                  isOutlined: true,
                  onPressed: controller.logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
