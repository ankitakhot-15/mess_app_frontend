import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/app_routes.dart';
import '../controllers/login_controller.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/responsive.dart';
import '../core/utils/validators.dart';
import '../widgets/app_logo.dart';
import '../widgets/common_button.dart';
import '../widgets/common_text_field.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(24), vertical: Responsive.w(16)),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Responsive.contentWidth),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: AppLogo(size: Responsive.w(190))),
                      SizedBox(height: Responsive.w(8)),
                      Text('स्वागत आहे! 🙏', style: AppTextStyles.heading),
                      SizedBox(height: Responsive.w(4)),
                      Text('तुमच्या खात्यात लॉगिन करा', style: AppTextStyles.bodyGrey),
                      SizedBox(height: Responsive.w(24)),
                      CommonTextField(
                        label: 'मोबाईल नंबर',
                        hint: '९८XXXXXXXX',
                        controller: controller.mobileController,
                        prefixIcon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: Validators.mobile,
                      ),
                      SizedBox(height: Responsive.w(16)),
                      CommonTextField(
                        label: 'पासवर्ड',
                        hint: '••••••',
                        controller: controller.passwordController,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        onSubmitted: (_) => controller.login(),
                      ),
                      SizedBox(height: Responsive.w(20)),
                      CommonButton(
                        text: 'लॉगिन करा',
                        icon: Icons.login_rounded,
                        onPressed: controller.login,
                      ),
                      SizedBox(height: Responsive.w(16)),
                      Row(children: [
                        const Expanded(child: Divider(color: AppColors.lightGrey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.w(12)),
                          child: Text('किंवा', style: AppTextStyles.bodyGrey),
                        ),
                        const Expanded(child: Divider(color: AppColors.lightGrey)),
                      ]),
                      SizedBox(height: Responsive.w(16)),
                      CommonButton(
                        text: 'नवीन खाते उघडा',
                        isOutlined: true,
                        onPressed: () => Get.toNamed(AppRoutes.register),
                      ),
                      SizedBox(height: Responsive.w(20)),
                      Center(
                        child: Text('घरच्या चवीसारखं... प्रेमाने! ❤️',
                            style: AppTextStyles.tagline),
                      ),
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
