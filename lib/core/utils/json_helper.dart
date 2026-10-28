/// Safe JSON readers – the backend may send numbers as strings, `_id` or `id`,
/// populated objects or plain ids. These helpers never throw.
class J {
  J._();

  static String str(dynamic v, [String d = '']) => v == null ? d : v.toString();

  static num number(dynamic v, [num d = 0]) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v) ?? d;
    return d;
  }

  static int integer(dynamic v, [int d = 0]) => number(v, d).toInt();

  static bool boolean(dynamic v, [bool d = false]) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    return d;
  }

  static Map<String, dynamic> map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static List<Map<String, dynamic>> list(dynamic v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];

  /// `id` or `_id` of an object.
  static String id(Map<String, dynamic> j) => str(j['id'] ?? j['_id']);

  /// Reference field that can be a plain id or a populated object.
  static String refId(dynamic v) => v is Map ? id(map(v)) : str(v);

  /// First non-empty string among [keys].
  static String firstStr(Map<String, dynamic> j, List<String> keys, [String d = '']) {
    for (final k in keys) {
      final v = j[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return d;
  }
}
