import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

const _cacheFileName = 'finnness_cache.json';

Future<Map<String, dynamic>> readCache() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$_cacheFileName');

  if (!await file.exists()) return {};

  try {
    final raw = await file.readAsString();
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
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$_cacheFileName');
  await file.writeAsString(jsonEncode(data));
}
