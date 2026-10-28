import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app_pages.dart';
import 'app/app_routes.dart';
import 'app/initial_binding.dart';
import 'core/app_colors.dart';
import 'core/utils/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MayechiChavApp());
}

class MayechiChavApp extends StatelessWidget {
  const MayechiChavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'मायेची चव',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.primaryOrange,
        ),
      ),
    );
  }
}
