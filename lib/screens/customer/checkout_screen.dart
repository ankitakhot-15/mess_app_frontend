import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../controllers/customer/checkout_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants/app_enums.dart';
import '../../core/responsive.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_text_field.dart';
import '../../widgets/panel.dart';

/// Cart review + plan + start date + address + payment + server price preview.
class CheckoutScreen extends GetView<CheckoutController> {
  const CheckoutScreen({super.key});

  CartController get cart => controller.cart;

  Widget _title(String t) => Padding(
        padding: EdgeInsets.only(top: Responsive.w(18), bottom: Responsive.w(8)),
        child: Text(t, style: AppTextStyles.subHeading),
      );

  Widget _lineTile(CartLine line) => Panel(
        margin: EdgeInsets.only(bottom: Responsive.w(8)),
        padding: EdgeInsets.all(Responsive.w(10)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.item.name, style: AppTextStyles.cardTitle),
                  Text('₹${line.item.priceFor(cart.plan.value)} × ${line.qty}  (${cart.plan.value.label})',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              onPressed: () => cart.remove(line.item.id),
              icon: const Icon(Icons.remove_circle_outline_rounded),
              color: AppColors.primaryOrange,
            ),
            Text('${line.qty}', style: AppTextStyles.cardTitle),
            IconButton(
              onPressed: () => cart.add(cart.mess.value!, line.item),
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: AppColors.primaryGreen,
            ),
          ],
        ),
      );

  Widget _planChips() => Obx(() => Wrap(
        spacing: Responsive.w(8),
        children: OrderPlan.values
            .map((p) => ChoiceChip(
                  label: Text('${p.label} (${p.days} दिवस)'),
                  selected: cart.plan.value == p,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: AppTextStyles.label.copyWith(
                      color: cart.plan.value == p ? Colors.white : AppColors.brown),
                  onSelected: (_) => cart.plan.value = p,
                ))
            .toList(),
      ));

  Widget _startDate() => Obx(() => Panel(
        onTap: controller.pickStartDate,
        child: Row(
          children: [
            const Icon(Icons.event_rounded, color: AppColors.primaryOrange),
            SizedBox(width: Responsive.w(10)),
            Expanded(
              child: Text(DateHelper.label(controller.startDate.value), style: AppTextStyles.body),
            ),
            Text('बदला', style: AppTextStyles.link),
          ],
        ),
      ));

  Widget _paymentOptions() => Obx(() => Column(
        children: PaymentMethod.values
            .map((m) => Panel(
                  margin: EdgeInsets.only(bottom: Responsive.w(8)),
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(8), vertical: Responsive.w(2)),
                  onTap: () => controller.payment.value = m,
                  child: Row(
                    children: [
                      Icon(
                        controller.payment.value == m
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: controller.payment.value == m
                            ? AppColors.primaryGreen
                            : AppColors.grey,
                      ),
                      SizedBox(width: Responsive.w(8)),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: Responsive.w(12)),
                          child: Text(m.label, style: AppTextStyles.body),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ));

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.w(3)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: bold ? AppTextStyles.subHeading : AppTextStyles.body),
            Text(value,
                style: bold
                    ? AppTextStyles.subHeading.copyWith(color: AppColors.primaryGreen)
                    : AppTextStyles.body),
          ],
        ),
      );

  /// price summary from the SERVER (subtotal + delivery charge + total)
  Widget _summary() => Obx(() {
        if (controller.previewLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
          );
        }
        if (controller.previewError.value != null) {
          return Column(
            children: [
              Text(controller.previewError.value!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.error)),
              if (controller.previewErrorCode.value != null)
                Text('Error code: ${controller.previewErrorCode.value}',
                    style: AppTextStyles.caption),
              TextButton(
                  onPressed: controller.loadPreview,
                  child: Text('पुन्हा प्रयत्न करा', style: AppTextStyles.link)),
            ],
          );
        }
        final p = controller.preview.value;
        if (p == null) return const SizedBox.shrink();
        return Column(
          children: [
            _row('आयटम एकूण', '₹${p.subtotal}'),
            _row('डिलिव्हरी चार्ज', p.deliveryCharge == 0 ? 'मोफत' : '₹${p.deliveryCharge}'),
            const Divider(color: AppColors.lightGrey),
            _row('एकूण रक्कम', '₹${p.total}', bold: true),
          ],
        );
      });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final gap = SizedBox(height: Responsive.w(12));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('चेकआउट', style: AppTextStyles.subHeading.copyWith(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Obx(() {
                if (cart.isEmpty) {
                  return Center(child: Text('कार्ट रिकामा आहे', style: AppTextStyles.bodyGrey));
                }
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(Responsive.w(16)),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cart.mess.value?.messName ?? '', style: AppTextStyles.heading),
                              gap,
                              ...cart.lines.values.map(_lineTile),
                              _title('प्लॅन'),
                              _planChips(),
                              _title('सुरुवातीची तारीख'),
                              _startDate(),
                              _title('डिलिव्हरी पत्ता'),
                              CommonTextField(
                                label: 'पत्ता',
                                hint: 'घर नं., गल्ली, परिसर',
                                controller: controller.addressController,
                                prefixIcon: Icons.home_outlined,
                                maxLines: 2,
                                validator: (v) => Validators.required(v, 'पत्ता'),
                              ),
                              gap,
                              CommonTextField(
                                label: 'परिसर / एरिया',
                                hint: 'उदा. राजारामपुरी',
                                controller: controller.areaNameController,
                                prefixIcon: Icons.map_outlined,
                              ),
                              gap,
                              CommonTextField(
                                label: 'पिनकोड',
                                hint: '४१६००१',
                                controller: controller.pincodeController,
                                prefixIcon: Icons.pin_drop_outlined,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                validator: Validators.pincode,
                              ),
                              gap,
                              CommonTextField(
                                label: 'सूचना (ऐच्छिक)',
                                hint: 'उदा. कमी तिखट',
                                controller: controller.notesController,
                                prefixIcon: Icons.edit_note_rounded,
                                maxLines: 2,
                                textInputAction: TextInputAction.done,
                              ),
                              _title('पेमेंट'),
                              _paymentOptions(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(Responsive.w(16)),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        border: Border(top: BorderSide(color: AppColors.lightGrey)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _summary(),
                          SizedBox(height: Responsive.w(10)),
                          CommonButton(
                            text: controller.payment.value == PaymentMethod.online
                                ? 'पेमेंट करा'
                                : 'ऑर्डर करा',
                            icon: Icons.check_circle_outline_rounded,
                            onPressed: controller.placeOrder,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
