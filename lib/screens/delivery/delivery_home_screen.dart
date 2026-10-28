import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/app_routes.dart';
import '../../controllers/delivery/delivery_home_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants/app_enums.dart';
import '../../core/responsive.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/utils/location_helper.dart';
import '../../model/order_model.dart';
import '../../widgets/common_button.dart';
import '../../widgets/live_location_card.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/order_card.dart';
import '../../widgets/panel.dart';
import '../../widgets/state_views.dart';

/// DELIVERY BOY dashboard – assigned orders + duty switch.
class DeliveryHomeScreen extends GetView<DeliveryHomeController> {
  const DeliveryHomeScreen({super.key});

  static const _pickupStatuses = {
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
  };

  Widget _dutyCard() => Obx(() => Panel(
        child: Row(
          children: [
            Icon(Icons.two_wheeler_rounded,
                color: controller.isAvailable.value
                    ? AppColors.primaryGreen
                    : AppColors.grey),
            SizedBox(width: Responsive.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      controller.isAvailable.value
                          ? 'तुम्ही ड्युटीवर आहात'
                          : 'तुम्ही ड्युटी बंद केली आहे',
                      style: AppTextStyles.cardTitle),
                  Text('ऑर्डर मिळण्यासाठी ड्युटी चालू ठेवा',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            Switch(
              value: controller.isAvailable.value,
              activeColor: AppColors.primaryGreen,
              onChanged: controller.toggleAvailability,
            ),
          ],
        ),
      ));

  /// Live GPS of the delivery boy (refreshes every 15 s).
  Widget _liveLocationCard() => LiveLocationCard(
        fetch: () async {
          final loc = await LocationService().current();
          if (loc == null) return null;
          return LiveLocation(
            lat: loc.lat,
            lng: loc.lng,
            areaName: loc.areaName,
            updatedAt: DateTime.now(),
          );
        },
      );

  Widget _typeTabs() => Obx(() => Row(
        children: [
          for (final t in const [
            ('active', 'सध्याच्या'),
            ('history', 'पूर्ण झालेल्या')
          ])
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: t.$1 == 'active' ? Responsive.w(8) : 0),
                child: GestureDetector(
                  onTap: () => controller.setType(t.$1),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: Responsive.w(12)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: controller.type.value == t.$1
                          ? AppColors.primaryGreen
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(Responsive.w(14)),
                      border: Border.all(
                          color: controller.type.value == t.$1
                              ? AppColors.primaryGreen
                              : AppColors.lightGrey),
                    ),
                    child: Text(t.$2,
                        style: AppTextStyles.cardTitle.copyWith(
                            color: controller.type.value == t.$1
                                ? AppColors.white
                                : AppColors.brown)),
                  ),
                ),
              ),
            ),
        ],
      ));

  Future<void> _trafficDialog(OrderModel o) async {
    const levels = [
      ('NORMAL', 'सामान्य'),
      ('MODERATE', 'मध्यम ट्रॅफिक (+१० मिनिटे)'),
      ('HEAVY', 'जास्त ट्रॅफिक (+२० मिनिटे)'),
    ];
    final level = await Get.dialog<String>(SimpleDialog(
      title: Text('ट्रॅफिक कसे आहे?', style: AppTextStyles.subHeading),
      children: levels
          .map((l) => SimpleDialogOption(
                onPressed: () => Get.back(result: l.$1),
                child: Text(l.$2, style: AppTextStyles.body),
              ))
          .toList(),
    ));
    if (level == null) return;
    final note = await AppDialogs.prompt(
        title: 'टीप (ऐच्छिक)',
        hint: 'उदा. रंकाळ्याजवळ जाम',
        confirmText: 'पाठवा');
    if (note == null) return;
    controller.reportTraffic(o, level, note);
  }

  List<Widget> _actions(OrderModel o) {
    if (controller.type.value != 'active') return const [];

    if (_pickupStatuses.contains(o.status)) {
      return [
        CommonButton(
          text: 'ऑर्डर उचलली – निघालो',
          icon: Icons.local_shipping_rounded,
          onPressed: () async {
            final locationOn = await LocationHelper.ensureLocationOn();
            if (!locationOn) return; // error message already shown
            controller.pickup(o); // runs only when location is ON
          },
        ),
      ];
    }
    if (o.status == OrderStatus.outForDelivery) {
      return [
        if (o.isCod)
          Padding(
            padding: EdgeInsets.only(bottom: Responsive.w(8)),
            child: Text('💵 ग्राहकाकडून ₹${o.total} घ्या (COD)',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.primaryOrange)),
          ),
        CommonButton(
          text: 'ट्रॅफिक कळवा',
          icon: Icons.traffic_rounded,
          isOutlined: true,
          onPressed: () => _trafficDialog(o),
        ),
        SizedBox(height: Responsive.w(8)),
        CommonButton(
          text: 'डिलिव्हर झाले',
          icon: Icons.check_circle_rounded,
          onPressed: () => controller.deliver(o),
        ),
      ];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
            controller.userName.isEmpty
                ? 'डिलिव्हरी'
                : 'नमस्कार, ${controller.userName}',
            style: AppTextStyles.subHeading.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'सूचना',
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.white),
          ),
          IconButton(
            tooltip: 'लॉगआउट',
            onPressed: controller.logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
                    _dutyCard(),
                    SizedBox(height: Responsive.w(14)),
                    _liveLocationCard(),
                    SizedBox(height: Responsive.w(14)),
                    _typeTabs(),
                    SizedBox(height: Responsive.w(14)),
                    Obx(() {
                      if (controller.isLoading.value) return const LoaderView();
                      if (controller.errorMessage.value != null) {
                        return ErrorView(
                            message: controller.errorMessage.value!,
                            code: controller.errorCode.value,
                            onRetry: controller.load);
                      }
                      if (controller.orders.isEmpty) {
                        return EmptyView(
                            emoji: '🛵',
                            text: controller.type.value == 'active'
                                ? 'सध्या तुम्हाला कोणतीही ऑर्डर दिलेली नाही'
                                : 'अजून कोणतीही डिलिव्हरी पूर्ण नाही');
                      }
                      return Column(
                        children: controller.orders
                            .map((o) => OrderCard(
                                  order: o,
                                  showCustomer: true,
                                  showMess: true,
                                  actions: _actions(o),
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
