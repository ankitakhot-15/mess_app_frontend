import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/responsive.dart';

/// Common text field with label, prefix icon, password toggle & validation.
class CommonTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  const CommonTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.onSubmitted,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool _obscure = true;

  OutlineInputBorder _border(Color color, [double width = 1.2]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.w(14)),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label),
        SizedBox(height: Responsive.w(6)),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          maxLength: widget.maxLength,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          onFieldSubmitted: widget.onSubmitted,
          style: AppTextStyles.body,
          cursorColor: AppColors.primaryGreen,
          decoration: InputDecoration(
            counterText: '',
            hintText: widget.hint,
            hintStyle: AppTextStyles.hint,
            errorStyle: AppTextStyles.error,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.w(16), vertical: Responsive.w(16)),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon,
                    color: AppColors.primaryOrange, size: Responsive.w(22)),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            enabledBorder: _border(AppColors.lightGrey),
            focusedBorder: _border(AppColors.primaryGreen, 1.8),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, 1.8),
          ),
        ),
      ],
    );
  }
}
