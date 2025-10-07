class MapUtils {
  static String getString(
    Map<String, dynamic> map,
    String key, {
    String defaultValue = 'N/A',
  }) {
    return map[key]?.toString() ?? defaultValue;
  }

  static int getInt(
    Map<String, dynamic> map,
    String key, {
    int defaultValue = 0,
  }) {
    if (map[key] == null) return defaultValue;
    if (map[key] is int) return map[key];
    if (map[key] is String) {
      return int.tryParse(map[key]) ?? defaultValue;
    }
    return defaultValue;
  }

  static double getDouble(
    Map<String, dynamic> map,
    String key, {
    double defaultValue = 0.0,
  }) {
    if (map[key] == null) return defaultValue;
    if (map[key] is double) return map[key];
    if (map[key] is String) {
      return double.tryParse(map[key]) ?? defaultValue;
    }
    if (map[key] is int) {
      return (map[key] as int).toDouble();
    }
    return defaultValue;
  }

  static bool getBool(
    Map<String, dynamic> map,
    String key, {
    bool defaultValue = false,
  }) {
    if (map[key] == null) return defaultValue;
    if (map[key] is bool) return map[key];
    if (map[key] is String) {
      return map[key].toLowerCase() == 'true';
    }
    if (map[key] is int) {
      return map[key] == 1;
    }
    return defaultValue;
  }

  static DateTime? getDateTime(Map<String, dynamic> map, String key) {
    if (map[key] == null) return null;
    if (map[key] is DateTime) return map[key];
    if (map[key] is String) {
      return DateTime.tryParse(map[key]);
    }
    if (map[key] is int) {
      return DateTime.fromMillisecondsSinceEpoch(map[key]);
    }
    return null;
  }
}
