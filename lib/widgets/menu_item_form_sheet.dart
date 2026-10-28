import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants/app_enums.dart';
import '../core/responsive.dart';
import '../core/utils/validators.dart';
import '../model/menu_item.dart';
import 'common_button.dart';
import 'common_dropdown.dart';
import 'common_text_field.dart';

/// Bottom sheet to add / edit a menu item (used at mavshi registration
/// and in the mavshi "Menu" tab).
///
/// [onSubmit] gets the API body. Return true to close the sheet.
class MenuItemFormSheet extends StatefulWidget {
  final MenuItem? initial;
  final FutureOr<bool> Function(Map<String, dynamic> body) onSubmit;

  const MenuItemFormSheet({super.key, this.initial, required this.onSubmit});

  static Future<void> show({
    MenuItem? initial,
    required FutureOr<bool> Function(Map<String, dynamic> body) onSubmit,
  }) =>
      Get.bottomSheet(
        MenuItemFormSheet(initial: initial, onSubmit: onSubmit),
        isScrollControlled: true,
        backgroundColor: AppColors.cream,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      );

  @override
  State<MenuItemFormSheet> createState() => _MenuItemFormSheetState();
}

class _MenuItemFormSheetState extends State<MenuItemFormSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _desc = TextEditingController(text: widget.initial?.description);
  late final _price = TextEditingController(text: widget.initial?.price.toString());
  late final _weekly = TextEditingController(text: widget.initial?.weeklyPrice?.toString());
  late final _monthly = TextEditingController(text: widget.initial?.monthlyPrice?.toString());
  late String _mealType =
      MealTypes.values.contains(widget.initial?.mealType) ? widget.initial!.mealType : 'LUNCH';
  late String _foodType =
      FoodTypes.values.contains(widget.initial?.foodType) ? widget.initial!.foodType : 'VEG';

  @override
  void dispose() {
    for (final c in [_name, _desc, _price, _weekly, _monthly]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'description': _desc.text.trim(),
      'mealType': _mealType,
      'foodType': _foodType,
      'price': num.parse(_price.text.trim()),
      if (_weekly.text.trim().isNotEmpty) 'weeklyPrice': num.parse(_weekly.text.trim()),
      if (_monthly.text.trim().isNotEmpty) 'monthlyPrice': num.parse(_monthly.text.trim()),
    };
    final ok = await widget.onSubmit(body);
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final gap = SizedBox(height: Responsive.w(12));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(20)),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.initial == null ? 'नवीन आयटम' : 'आयटम बदला',
                  style: AppTextStyles.heading),
              gap,
              CommonTextField(
                label: 'नाव',
                hint: 'उदा. व्हेज थाळी',
                controller: _name,
                validator: (v) => Validators.required(v, 'नाव'),
              ),
              gap,
              CommonTextField(
                label: 'वर्णन',
                hint: '२ चपाती, भाजी, भात, वरण',
                controller: _desc,
                maxLines: 2,
              ),
              gap,
              CommonDropdown<String>(
                label: 'जेवणाची वेळ',
                value: _mealType,
                items: MealTypes.values,
                itemLabel: MealTypes.label,
                onChanged: (v) => setState(() => _mealType = v),
              ),
              gap,
              CommonDropdown<String>(
                label: 'प्रकार',
                value: _foodType,
                items: FoodTypes.values,
                itemLabel: FoodTypes.label,
                onChanged: (v) => setState(() => _foodType = v),
              ),
              gap,
              CommonTextField(
                label: 'दिवसाची किंमत (₹)',
                hint: '80',
                controller: _price,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.positiveNumber(v, 'किंमत'),
              ),
              gap,
              CommonTextField(
                label: 'आठवड्याची किंमत (ऐच्छिक)',
                hint: 'रिकामे ठेवल्यास किंमत × ७',
                controller: _weekly,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.optionalPositiveNumber(v, 'किंमत'),
              ),
              gap,
              CommonTextField(
                label: 'महिन्याची किंमत (ऐच्छिक)',
                hint: 'रिकामे ठेवल्यास किंमत × ३०',
                controller: _monthly,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (v) => Validators.optionalPositiveNumber(v, 'किंमत'),
              ),
              SizedBox(height: Responsive.w(18)),
              CommonButton(text: 'सेव्ह करा', icon: Icons.check_rounded, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
