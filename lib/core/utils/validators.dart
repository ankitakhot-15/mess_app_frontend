/// Common form validators (Marathi messages). Rules follow the API document.
class Validators {
  Validators._();

  static String? required(String? v, String field) =>
      (v == null || v.trim().isEmpty) ? 'कृपया $field टाका' : null;

  /// 10 digits, starts with 6-9
  static String? mobile(String? v) {
    final r = required(v, 'मोबाईल नंबर');
    if (r != null) return r;
    return RegExp(r'^[6-9]\d{9}$').hasMatch(v!.trim())
        ? null
        : 'योग्य १० अंकी मोबाईल नंबर टाका';
  }

  /// 6 digits
  static String? pincode(String? v) {
    final r = required(v, 'पिनकोड');
    if (r != null) return r;
    return RegExp(r'^\d{6}$').hasMatch(v!.trim()) ? null : 'योग्य ६ अंकी पिनकोड टाका';
  }

  /// optional field – validated only when filled
  static String? optionalEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())
        ? null
        : 'योग्य ईमेल टाका';
  }

  /// 8-64 characters
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'कृपया पासवर्ड टाका';
    if (v.length < 8 || v.length > 64) return 'पासवर्ड ८ ते ६४ अक्षरांचा असावा';
    return null;
  }

  static String? positiveNumber(String? v, String field) {
    final r = required(v, field);
    if (r != null) return r;
    final n = num.tryParse(v!.trim());
    return (n == null || n <= 0) ? '$field योग्य टाका' : null;
  }

  static String? optionalPositiveNumber(String? v, String field) {
    if (v == null || v.trim().isEmpty) return null;
    final n = num.tryParse(v.trim());
    return (n == null || n <= 0) ? '$field योग्य टाका' : null;
  }

  static String? minLength(String? v, String field, int min) {
    final r = required(v, field);
    if (r != null) return r;
    return v!.trim().length < min ? '$field किमान $min अक्षरांचा असावा' : null;
  }
}
