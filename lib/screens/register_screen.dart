import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants/app_enums.dart';
import '../core/responsive.dart';
import '../core/utils/validators.dart';
import '../widgets/common_button.dart';
import '../widgets/common_dropdown.dart';
import '../widgets/common_text_field.dart';
import '../widgets/menu_item_form_sheet.dart';
import '../widgets/panel.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  static String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.delivery:
        return 'डिलिव्हरी बॉय';
      case UserRole.mavshi:
        return 'मावशी (मेस)';
      default:
        return 'ग्राहक';
    }
  }

  static String _vehicleLabel(String v) {
    switch (v) {
      case 'SCOOTER':
        return 'स्कूटर';
      case 'CYCLE':
        return 'सायकल';
      default:
        return 'बाईक';
    }
  }

  Widget _roleSelector() => Obx(() => Wrap(
        spacing: Responsive.w(8),
        children: RegisterController.roles
            .map((r) => ChoiceChip(
                  label: Text(_roleLabel(r)),
                  selected: controller.role.value == r,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: AppTextStyles.label.copyWith(
                      color: controller.role.value == r ? Colors.white : AppColors.brown),
                  onSelected: (_) => controller.role.value = r,
                ))
            .toList(),
      ));

  /// approved areas – tap to fill pincode + area
  Widget _areaChips() => Obx(() {
        if (controller.areas.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: Responsive.w(8)),
          child: Wrap(
            spacing: Responsive.w(6),
            runSpacing: Responsive.w(4),
            children: controller.areas
                .map((a) => ActionChip(
                      label: Text(
                          a.areaName.isEmpty ? a.pincode : '${a.areaName} (${a.pincode})',
                          style: AppTextStyles.caption),
                      onPressed: () => controller.pickArea(a),
                    ))
                .toList(),
          ),
        );
      });

  Widget _delivery(SizedBox gap) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gap,
          Obx(() => CommonDropdown<String>(
                label: 'वाहन प्रकार',
                value: controller.vehicleType.value,
                items: const ['BIKE', 'SCOOTER', 'CYCLE'],
                itemLabel: _vehicleLabel,
                prefixIcon: Icons.two_wheeler_rounded,
                onChanged: (v) => controller.vehicleType.value = v,
              )),
          gap,
          CommonTextField(
            label: 'वाहन क्रमांक (ऐच्छिक)',
            hint: 'MH09AB1234',
            controller: controller.vehicleNumberController,
            prefixIcon: Icons.confirmation_number_outlined,
          ),
          gap,
          CommonTextField(
            label: 'लायसन्स क्रमांक (ऐच्छिक)',
            hint: 'MH0920200001234',
            controller: controller.licenseNumberController,
            prefixIcon: Icons.badge_outlined,
          ),
        ],
      );

  Widget _mavshi(SizedBox gap) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gap,
          CommonTextField(
            label: 'मेसचे नाव',
            hint: 'उदा. सुनीता मेस',
            controller: controller.messNameController,
            prefixIcon: Icons.storefront_rounded,
            validator: (v) => Validators.required(v, 'मेसचे नाव'),
          ),
          gap,
          CommonTextField(
            label: 'स्वयंपाकाचा अनुभव (वर्षे)',
            hint: '८',
            controller: controller.experienceController,
            prefixIcon: Icons.timer_outlined,
            keyboardType: TextInputType.number,
            maxLength: 2,
            validator: (v) {
              final r = Validators.required(v, 'अनुभव');
              if (r != null) return r;
              return int.tryParse(v!.trim()) == null ? 'योग्य संख्या टाका' : null;
            },
          ),
          gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CommonTextField(
                  label: 'मेस सुरू (महिना)',
                  hint: '६',
                  controller: controller.startMonthController,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    return (n == null || n < 1 || n > 12) ? '१ ते १२' : null;
                  },
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: CommonTextField(
                  label: 'मेस सुरू (वर्ष)',
                  hint: '2019',
                  controller: controller.startYearController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    return (n == null || n < 1950 || n > DateTime.now().year)
                        ? 'योग्य वर्ष टाका'
                        : null;
                  },
                ),
              ),
            ],
          ),
          gap,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('मेनू आणि किंमत', style: AppTextStyles.label),
              TextButton.icon(
                onPressed: () => MenuItemFormSheet.show(onSubmit: (body) {
                  controller.addPricing(body);
                  return true;
                }),
                icon: const Icon(Icons.add_rounded, color: AppColors.primaryOrange),
                label: Text('आयटम जोडा', style: AppTextStyles.link),
              ),
            ],
          ),
          Obx(() {
            if (controller.pricing.isEmpty) {
              return Text('किमान एक आयटम जोडा.', style: AppTextStyles.bodyGrey);
            }
            return Column(
              children: [
                for (var i = 0; i < controller.pricing.length; i++)
                  Panel(
                    margin: EdgeInsets.only(bottom: Responsive.w(8)),
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(12), vertical: Responsive.w(8)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${controller.pricing[i]['name']}',
                                  style: AppTextStyles.cardTitle),
                              Text(
                                  '${MealTypes.label('${controller.pricing[i]['mealType']}')} • ₹${controller.pricing[i]['price']}',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.removePricing(i),
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      );

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final gap = SizedBox(height: Responsive.w(14));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brown),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(24), vertical: Responsive.w(8)),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Responsive.contentWidth),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('नवीन खाते उघडा', style: AppTextStyles.heading),
                      SizedBox(height: Responsive.w(4)),
                      Text('तुम्ही कोण आहात?', style: AppTextStyles.bodyGrey),
                      SizedBox(height: Responsive.w(10)),
                      _roleSelector(),
                      SizedBox(height: Responsive.w(18)),
                      CommonTextField(
                        label: 'पूर्ण नाव',
                        hint: 'उदा. राहुल पाटील',
                        controller: controller.fullNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => Validators.minLength(v, 'पूर्ण नाव', 2),
                      ),
                      gap,
                      CommonTextField(
                        label: 'मोबाईल नंबर',
                        hint: '९८XXXXXXXX',
                        controller: controller.mobileController,
                        prefixIcon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: Validators.mobile,
                      ),
                      gap,
                      Obx(() => controller.role.value == UserRole.customer
                          ? Padding(
                              padding: EdgeInsets.only(bottom: Responsive.w(14)),
                              child: CommonTextField(
                                label: 'ईमेल (ऐच्छिक)',
                                hint: 'name@example.com',
                                controller: controller.emailController,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.optionalEmail,
                              ),
                            )
                          : const SizedBox.shrink()),
                      CommonTextField(
                        label: 'पत्ता',
                        hint: 'घर नं., गल्ली, परिसर',
                        controller: controller.addressController,
                        prefixIcon: Icons.home_outlined,
                        keyboardType: TextInputType.streetAddress,
                        maxLines: 2,
                        validator: (v) => Validators.required(v, 'पत्ता'),
                      ),
                      gap,
                      CommonTextField(
                        label: 'परिसर / एरिया',
                        hint: 'उदा. राजारामपुरी',
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
                        validator: Validators.pincode,
                      ),
                      _areaChips(),
                      Obx(() {
                        switch (controller.role.value) {
                          case UserRole.delivery:
                            return _delivery(gap);
                          case UserRole.mavshi:
                            return _mavshi(gap);
                          default:
                            return const SizedBox.shrink();
                        }
                      }),
                      gap,
                      CommonTextField(
                        label: 'पासवर्ड',
                        hint: '८ ते ६४ अक्षरे',
                        controller: controller.passwordController,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        onSubmitted: (_) => controller.register(),
                      ),
                      SizedBox(height: Responsive.w(22)),
                      CommonButton(
                        text: 'खाते उघडा',
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: controller.register,
                      ),
                      SizedBox(height: Responsive.w(12)),
                      Center(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: Text('आधीच खाते आहे? लॉगिन करा', style: AppTextStyles.link),
                        ),
                      ),
                      SizedBox(height: Responsive.w(12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
