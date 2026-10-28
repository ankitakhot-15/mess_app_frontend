import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

/// Common confirm / text-input dialogs.
class AppDialogs {
  AppDialogs._();

  static Future<bool> confirm({
    required String title,
    required String message,
    String yes = 'होय',
    String no = 'नाही',
  }) async {
    final r = await Get.dialog<bool>(AlertDialog(
      backgroundColor: AppColors.white,
      title: Text(title, style: AppTextStyles.subHeading),
      content: Text(message, style: AppTextStyles.body),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(no, style: AppTextStyles.link.copyWith(color: AppColors.grey))),
        TextButton(
            onPressed: () => Get.back(result: true), child: Text(yes, style: AppTextStyles.link)),
      ],
    ));
    return r ?? false;
  }

  /// Returns the typed text, or null when cancelled.
  static Future<String?> prompt({
    required String title,
    required String hint,
    String confirmText = 'ठीक आहे',
    bool required = false,
    int minLength = 0,
  }) =>
      Get.dialog<String>(_PromptDialog(
        title: title,
        hint: hint,
        confirmText: confirmText,
        required: required,
        minLength: minLength,
      ));
}

class _PromptDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String confirmText;
  final bool required;
  final int minLength;

  const _PromptDialog({
    required this.title,
    required this.hint,
    required this.confirmText,
    required this.required,
    required this.minLength,
  });

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  final _c = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _c.text.trim();
    if (widget.required && t.isEmpty) {
      setState(() => _error = 'कृपया माहिती टाका');
      return;
    }
    if (t.length < widget.minLength && (widget.required || t.isNotEmpty)) {
      setState(() => _error = 'किमान ${widget.minLength} अक्षरे टाका');
      return;
    }
    Get.back(result: t);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: Text(widget.title, style: AppTextStyles.subHeading),
      content: TextField(
        controller: _c,
        maxLines: 3,
        maxLength: 300,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hint, errorText: _error),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: Text('रद्द करा', style: AppTextStyles.link.copyWith(color: AppColors.grey))),
        TextButton(onPressed: _submit, child: Text(widget.confirmText, style: AppTextStyles.link)),
      ],
    );
  }
}
