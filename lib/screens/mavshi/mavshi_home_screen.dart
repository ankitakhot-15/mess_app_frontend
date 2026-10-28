import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/app_routes.dart';
import '../../controllers/mavshi/mavshi_home_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants/app_enums.dart';
import '../../core/responsive.dart';
import '../../core/utils/storage_service.dart';
import '../../core/utils/validators.dart';
import '../../model/menu_item.dart';
import '../../model/misc_models.dart';
import '../../model/order_model.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_text_field.dart';
import '../../widgets/menu_item_form_sheet.dart';
import '../../widgets/order_card.dart';
import '../../widgets/panel.dart';
import '../../widgets/state_views.dart';

/// MAVSHI (mess owner) dashboard.
///  PENDING / REJECTED -> status screen (rejected can edit + resubmit)
///  ACTIVE             -> orders tab + menu tab
class MavshiHomeScreen extends GetView<MavshiHomeController> {
  const MavshiHomeScreen({super.key});

  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(controller.messName,
            style: AppTextStyles.subHeading.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'सूचना',
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          ),
          IconButton(
            tooltip: 'लॉगआउट',
            onPressed: controller.logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ],
      );

  // ------------------------------------------------------------------ status view
  Widget _statusView(MavshiStatus s) {
    final pending = s.isPending;
    final rejected = s.isRejected;
    final icon = pending
        ? Icons.hourglass_top_rounded
        : (rejected ? Icons.cancel_rounded : Icons.block_rounded);
    final color = pending ? AppColors.primaryOrange : AppColors.error;
    final title = pending
        ? 'अ‍ॅडमिनच्या मंजुरीची प्रतीक्षा'
        : (rejected ? 'विनंती नाकारली' : 'खाते बंद आहे (${s.status})');
    final message = pending
        ? 'तुमची मेस नोंदणी तपासली जात आहे. मंजूर झाल्यावर तुम्हाला सूचना मिळेल.'
        : (s.rejectionReason.isNotEmpty ? s.rejectionReason : 'कृपया अ‍ॅडमिनशी संपर्क साधा.');

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(Responsive.w(20)),
      children: [
        SizedBox(height: Responsive.w(30)),
        Icon(icon, size: Responsive.w(80), color: color),
        SizedBox(height: Responsive.w(12)),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.heading.copyWith(color: color)),
        SizedBox(height: Responsive.w(8)),
        Text(message, textAlign: TextAlign.center, style: AppTextStyles.body),
        SizedBox(height: Responsive.w(24)),
        CommonButton(
            text: 'स्थिती तपासा', icon: Icons.refresh_rounded, onPressed: controller.loadStatus),
        if (rejected) ...[
          SizedBox(height: Responsive.w(12)),
          CommonButton(
            text: 'माहिती सुधारा आणि पुन्हा पाठवा',
            icon: Icons.edit_rounded,
            isOutlined: true,
            onPressed: _openResubmit,
          ),
        ],
      ],
    );
  }

  void _openResubmit() {
    final u = StorageService.user;
    final form = GlobalKey<FormState>();
    final mess = TextEditingController(text: u?.messName ?? '');
    final address = TextEditingController(text: u?.address ?? '');
    final area = TextEditingController(text: u?.areaName ?? '');
    final pin = TextEditingController(text: u?.pincode ?? '');
    final gap = SizedBox(height: Responsive.w(12));

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(20)),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('माहिती सुधारा', style: AppTextStyles.heading),
                gap,
                CommonTextField(
                    label: 'मेसचे नाव',
                    hint: 'मेसचे नाव',
                    controller: mess,
                    validator: (v) => Validators.required(v, 'मेसचे नाव')),
                gap,
                CommonTextField(
                    label: 'पत्ता',
                    hint: 'पत्ता',
                    controller: address,
                    maxLines: 2,
                    validator: (v) => Validators.required(v, 'पत्ता')),
                gap,
                CommonTextField(
                    label: 'परिसर / एरिया',
                    hint: 'परिसर',
                    controller: area,
                    validator: (v) => Validators.required(v, 'परिसर')),
                gap,
                CommonTextField(
                    label: 'पिनकोड',
                    hint: '४१६००१',
                    controller: pin,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textInputAction: TextInputAction.done,
                    validator: Validators.pincode),
                SizedBox(height: Responsive.w(16)),
                CommonButton(
                  text: 'पुन्हा पाठवा',
                  icon: Icons.send_rounded,
                  onPressed: () {
                    if (!(form.currentState?.validate() ?? false)) return;
                    Get.back();
                    controller.resubmitProfile({
                      'messName': mess.text.trim(),
                      'address': address.text.trim(),
                      'areaName': area.text.trim(),
                      'pincode': pin.text.trim(),
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    );
  }

  // ------------------------------------------------------------------ orders tab
  List<Widget> _orderActions(OrderModel o) {
    String? next;
    String? label;
    if (o.status == OrderStatus.accepted) {
      next = OrderStatus.preparing;
      label = 'तयारी सुरू करा';
    } else if (o.status == OrderStatus.preparing) {
      next = OrderStatus.ready;
      label = 'तयार आहे';
    }
    if (next == null) return const [];
    final target = next;
    return [
      CommonButton(
        text: label!,
        icon: Icons.restaurant_rounded,
        onPressed: () => controller.updateOrderStatus(o, target),
      ),
    ];
  }

  Widget _ordersTab() => RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: controller.loadOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(Responsive.w(16)),
          children: [
            SizedBox(
              height: Responsive.w(40),
              child: Obx(() => ListView(
                    scrollDirection: Axis.horizontal,
                    children: MavshiHomeController.orderFilters
                        .map((f) => Padding(
                              padding: EdgeInsets.only(right: Responsive.w(8)),
                              child: ChoiceChip(
                                label: Text(f == null ? 'सर्व' : OrderStatus.label(f)),
                                selected: controller.orderFilter.value == f,
                                selectedColor: AppColors.primaryGreen,
                                labelStyle: AppTextStyles.caption.copyWith(
                                    color: controller.orderFilter.value == f
                                        ? Colors.white
                                        : AppColors.brown,
                                    fontWeight: FontWeight.w700),
                                onSelected: (_) => controller.setOrderFilter(f),
                              ),
                            ))
                        .toList(),
                  )),
            ),
            SizedBox(height: Responsive.w(12)),
            Obx(() {
              if (controller.ordersLoading.value) return const LoaderView();
              if (controller.ordersError.value != null) {
                return ErrorView(
                    message: controller.ordersError.value!,
                    code: controller.ordersErrorCode.value,
                    onRetry: controller.loadOrders);
              }
              if (controller.orders.isEmpty) {
                return const EmptyView(emoji: '🧾', text: 'अजून ऑर्डर नाहीत');
              }
              return Column(
                children: controller.orders
                    .map((o) => OrderCard(order: o, showCustomer: true, actions: _orderActions(o)))
                    .toList(),
              );
            }),
          ],
        ),
      );

  // ------------------------------------------------------------------ menu tab
  Widget _menuTile(MenuItem m) => Panel(
        margin: EdgeInsets.only(bottom: Responsive.w(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle,
                    size: Responsive.w(10),
                    color: m.isVeg ? AppColors.primaryGreen : AppColors.heartRed),
                SizedBox(width: Responsive.w(6)),
                Expanded(child: Text(m.name, style: AppTextStyles.cardTitle)),
                Switch(
                  value: m.available,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (v) => controller.toggleAvailable(m, v),
                ),
              ],
            ),
            if (m.description.isNotEmpty) Text(m.description, style: AppTextStyles.caption),
            Text('${MealTypes.label(m.mealType)} • ${FoodTypes.label(m.foodType)}',
                style: AppTextStyles.caption),
            SizedBox(height: Responsive.w(4)),
            Text(
                '₹${m.price} / दिवस   ₹${m.weeklyPrice ?? m.price * 7} / आठवडा   ₹${m.monthlyPrice ?? m.price * 30} / महिना',
                style: AppTextStyles.label.copyWith(color: AppColors.primaryOrange)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => MenuItemFormSheet.show(
                    initial: m,
                    onSubmit: (body) => controller.saveMenuItem(body, editId: m.id),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primaryGreen),
                  label: Text('बदला', style: AppTextStyles.link.copyWith(color: AppColors.primaryGreen)),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final ok = await Get.dialog<bool>(AlertDialog(
                      title: const Text('आयटम काढायचा?'),
                      content: Text(m.name),
                      actions: [
                        TextButton(onPressed: () => Get.back(result: false), child: const Text('नाही')),
                        TextButton(onPressed: () => Get.back(result: true), child: const Text('होय')),
                      ],
                    ));
                    if (ok == true) controller.deleteMenuItem(m);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                  label: Text('काढा', style: AppTextStyles.link.copyWith(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _menuTab() => RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: controller.loadMenu,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(Responsive.w(16)),
          children: [
            Obx(() {
              if (controller.menuLoading.value) return const LoaderView();
              if (controller.menuError.value != null) {
                return ErrorView(
                    message: controller.menuError.value!,
                    code: controller.menuErrorCode.value,
                    onRetry: controller.loadMenu);
              }
              if (controller.menu.isEmpty) {
                return const EmptyView(text: 'मेनू रिकामा आहे. + दाबून आयटम जोडा.');
              }
              return Column(children: controller.menu.map(_menuTile).toList());
            }),
            SizedBox(height: Responsive.w(70)),
          ],
        ),
      );

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: _appBar(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Obx(() {
            if (controller.statusLoading.value) return const Center(child: LoaderView());
            if (controller.statusError.value != null) {
              return ListView(
                padding: EdgeInsets.all(Responsive.w(16)),
                children: [
                  ErrorView(
                      message: controller.statusError.value!,
                      code: controller.statusErrorCode.value,
                      onRetry: controller.loadStatus),
                ],
              );
            }
            final s = controller.status.value;
            if (s == null) return const SizedBox.shrink();
            if (!s.isActive) return _statusView(s);
            return controller.tab.value == 0 ? _ordersTab() : _menuTab();
          }),
        ),
      ),
      floatingActionButton: Obx(() {
        final active = controller.status.value?.isActive ?? false;
        if (!active || controller.tab.value != 1) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          backgroundColor: AppColors.primaryOrange,
          onPressed: () => MenuItemFormSheet.show(
              onSubmit: (body) => controller.saveMenuItem(body)),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('आयटम जोडा', style: AppTextStyles.button),
        );
      }),
      bottomNavigationBar: Obx(() {
        final active = controller.status.value?.isActive ?? false;
        if (!active) return const SizedBox.shrink();
        return NavigationBar(
          selectedIndex: controller.tab.value,
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.primaryGreen.withOpacity(0.15),
          onDestinationSelected: (i) => controller.tab.value = i,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'ऑर्डर'),
            NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu_rounded),
                label: 'मेनू'),
          ],
        );
      }),
    );
  }
}
