import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer/order_detail_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants/app_enums.dart';
import '../../core/responsive.dart';
import '../../core/utils/date_helper.dart';
import '../../model/order_model.dart';
import '../../model/tracking_model.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/common_button.dart';
import '../../widgets/panel.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';

/// Order detail + live tracking + cancel (only while PLACED).
class OrderDetailScreen extends GetView<OrderDetailController> {
  const OrderDetailScreen({super.key});

  Widget _kv(String k, String v, {bool bold = false}) => Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.w(3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: bold ? AppTextStyles.subHeading : AppTextStyles.bodyGrey),
            SizedBox(width: Responsive.w(12)),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: bold
                      ? AppTextStyles.subHeading.copyWith(color: AppColors.primaryGreen)
                      : AppTextStyles.body),
            ),
          ],
        ),
      );

  Widget _tracking(TrackingModel t) => Panel(
        margin: EdgeInsets.only(bottom: Responsive.w(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.delivery_dining_rounded, color: AppColors.primaryOrange),
              SizedBox(width: Responsive.w(8)),
              Text('ट्रॅकिंग', style: AppTextStyles.cardTitle),
            ]),
            if (t.message.isNotEmpty) ...[
              SizedBox(height: Responsive.w(8)),
              Text(t.message, style: AppTextStyles.body),
            ],
            if (t.deliveryBoyName.isNotEmpty)
              _kv('डिलिव्हरी बॉय',
                  '${t.deliveryBoyName}${t.deliveryBoyMobile.isEmpty ? '' : '\n${t.deliveryBoyMobile}'}'),
            if (t.areaName.isNotEmpty) _kv('सध्याचे ठिकाण', t.areaName),
            if (t.timeline.isNotEmpty) ...[
              const Divider(color: AppColors.lightGrey),
              ...t.timeline.map((e) => Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.w(3)),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: Responsive.w(10), color: OrderStatus.color(e.status)),
                        SizedBox(width: Responsive.w(8)),
                        Expanded(
                          child: Text(
                              '${OrderStatus.label(e.status)}${e.note.isEmpty ? '' : ' – ${e.note}'}',
                              style: AppTextStyles.body),
                        ),
                        if (e.time.isNotEmpty)
                          Text(DateHelper.fromApi(e.time), style: AppTextStyles.caption),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      );

  Widget _body(OrderModel o) {
    final address = [o.address, o.areaName, o.pincode].where((s) => s.isNotEmpty).join(', ');
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(Responsive.w(16)),
      children: [
        Row(
          children: [
            Expanded(child: Text('ऑर्डर #${o.shortId}', style: AppTextStyles.heading)),
            StatusChip(o.status),
          ],
        ),
        SizedBox(height: Responsive.w(12)),
        if (o.status == OrderStatus.rejected && o.rejectionReason.isNotEmpty)
          Panel(
            margin: EdgeInsets.only(bottom: Responsive.w(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('नाकारण्याचे कारण', style: AppTextStyles.cardTitle),
                Text(o.rejectionReason, style: AppTextStyles.body),
                if (o.refundInfo.isNotEmpty) ...[
                  SizedBox(height: Responsive.w(6)),
                  Text('रिफंड: ${o.refundInfo}', style: AppTextStyles.bodyGrey),
                ],
              ],
            ),
          )
        else if (o.refundInfo.isNotEmpty)
          Panel(
            margin: EdgeInsets.only(bottom: Responsive.w(12)),
            child: Text('रिफंड: ${o.refundInfo}', style: AppTextStyles.body),
          ),
        Obx(() {
          final t = controller.tracking.value;
          return t == null ? const SizedBox.shrink() : _tracking(t);
        }),
        Panel(
          margin: EdgeInsets.only(bottom: Responsive.w(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('आयटम', style: AppTextStyles.cardTitle),
              SizedBox(height: Responsive.w(6)),
              ...o.items.map((i) => _kv('${i.name} × ${i.quantity}', '₹${i.price * i.quantity}')),
              const Divider(color: AppColors.lightGrey),
              _kv('आयटम एकूण', '₹${o.subtotal}'),
              _kv('डिलिव्हरी चार्ज', o.deliveryCharge == 0 ? 'मोफत' : '₹${o.deliveryCharge}'),
              _kv('एकूण रक्कम', '₹${o.total}', bold: true),
            ],
          ),
        ),
        Panel(
          margin: EdgeInsets.only(bottom: Responsive.w(12)),
          child: Column(
            children: [
              if (o.messName.isNotEmpty) _kv('मेस', o.messName),
              if (o.plan.isNotEmpty) _kv('प्लॅन', o.plan),
              if (o.startDate.isNotEmpty) _kv('सुरुवात', DateHelper.fromApi(o.startDate)),
              _kv('पेमेंट',
                  '${o.isCod ? 'कॅश ऑन डिलिव्हरी' : 'ऑनलाइन'}${o.paymentStatus.isEmpty ? '' : ' (${o.paymentStatus})'}'),
              if (address.isNotEmpty) _kv('पत्ता', address),
              if (o.notes.isNotEmpty) _kv('सूचना', o.notes),
            ],
          ),
        ),
        Obx(() => controller.canCancel
            ? CommonButton(
                text: 'ऑर्डर रद्द करा',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                onPressed: controller.cancel,
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('ऑर्डर तपशील', style: AppTextStyles.subHeading.copyWith(color: Colors.white)),
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
                child: Obx(() {
                  final o = controller.order.value;
                  if (controller.isLoading.value && o == null) {
                    return ListView(children: const [LoaderView()]);
                  }
                  if (controller.errorMessage.value != null && o == null) {
                    return ListView(
                      padding: EdgeInsets.all(Responsive.w(16)),
                      children: [
                        ErrorView(
                            message: controller.errorMessage.value!,
                            code: controller.errorCode.value,
                            onRetry: controller.load),
                      ],
                    );
                  }
                  if (o == null) return ListView();
                  return _body(o);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
