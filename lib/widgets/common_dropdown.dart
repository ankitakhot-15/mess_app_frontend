import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/responsive.dart';

/// Label + dropdown with the same look as [CommonTextField].
class CommonDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;
  final IconData? prefixIcon;

  const CommonDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.prefixIcon,
  });

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.w(14)),
        borderSide: BorderSide(color: c, width: 1.2),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: Responsive.w(6)),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.w(16), vertical: Responsive.w(12)),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.primaryOrange, size: Responsive.w(22)),
            enabledBorder: _border(AppColors.lightGrey),
            focusedBorder: _border(AppColors.primaryGreen),
          ),
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e))))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
