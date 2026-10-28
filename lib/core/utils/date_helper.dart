class DateHelper {
  DateHelper._();

  static const _weekdays = [
    'सोमवार', 'मंगळवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'
  ];
  static const _months = [
    'जानेवारी', 'फेब्रुवारी', 'मार्च', 'एप्रिल', 'मे', 'जून',
    'जुलै', 'ऑगस्ट', 'सप्टेंबर', 'ऑक्टोबर', 'नोव्हेंबर', 'डिसेंबर'
  ];

  static String label(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

  /// API format YYYY-MM-DD
  static String api(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Pretty label for an API / ISO date string; returns the input if it can't be parsed.
  static String fromApi(String s) {
    final d = DateTime.tryParse(s);
    if (d == null) return s;
    final l = d.toLocal();
    return '${l.day} ${_months[l.month - 1]} ${l.year}';
  }
}
