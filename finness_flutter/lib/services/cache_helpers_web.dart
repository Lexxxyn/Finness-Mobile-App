// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

const _cacheKey = 'finnness_cache';

Future<Map<String, dynamic>> readCache() async {
  final raw = html.window.localStorage[_cacheKey];
  if (raw == null || raw.isEmpty) return {};

  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  } catch (_) {
    return {};
  }

  return {};
}

Future<void> writeCache(Map<String, dynamic> data) async {
  html.window.localStorage[_cacheKey] = jsonEncode(data);
}
