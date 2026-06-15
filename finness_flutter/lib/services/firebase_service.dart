import 'package:firebase_database/firebase_database.dart';
import 'cache_helpers.dart' if (dart.library.html) 'cache_helpers_web.dart';

import '../models/models.dart' show UserProfile;

export '../models/models.dart' show UserProfile;

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  static const _pendingKey = 'finnness:pending_writes';
  static const _networkTimeout = Duration(seconds: 6);

  String cacheKey(String uid, String kind) => 'finnness:$uid:$kind';

  Future<T?> cachedFetch<T>({
    required String uid,
    required String kind,
    required String path,
    required T Function(dynamic value) fromValue,
  }) async {
    try {
      final snap = await _database.ref(path).get().timeout(_networkTimeout);
      final value = snap.exists ? snap.value : null;
      await _setCache(cacheKey(uid, kind), value);
      return value == null ? null : fromValue(value);
    } catch (_) {
      final cached = await _getCache(cacheKey(uid, kind));
      return cached == null ? null : fromValue(cached);
    }
  }

  Future<void> setValue(String path, Object? value) {
    return _writeNow(
      PendingWrite(path: path, value: value, operation: PendingOperation.set),
    );
  }

  Future<void> updateValue(String path, Map<String, Object?> value) {
    return _writeNow(
      PendingWrite(
        path: path,
        value: value,
        operation: PendingOperation.update,
      ),
    );
  }

  Future<void> removeValue(String path) {
    return _writeNow(
      PendingWrite(path: path, operation: PendingOperation.remove),
    );
  }

  Future<Object?> getValue(String path) async {
    final snap = await _database.ref(path).get().timeout(_networkTimeout);
    return snap.exists ? snap.value : null;
  }

  Future<int> flushPending() async {
    final list = await _loadPending();
    if (list.isEmpty) return 0;

    final remaining = <PendingWrite>[];
    var success = 0;

    for (final write in list) {
      try {
        await _applyWrite(write);
        success += 1;
      } catch (_) {
        remaining.add(write);
      }
    }

    await _savePending(remaining);
    return success;
  }

  Future<UserProfile?> fetchProfile(String uid) {
    return cachedFetch<UserProfile>(
      uid: uid,
      kind: 'profile',
      path: 'finnness/users/$uid/profile',
      fromValue: (value) => UserProfile.fromJson(_asStringMap(value)),
    );
  }

  Future<void> saveProfile(String uid, Map<String, Object?> profile) async {
    final cleaned = <String, Object?>{};

    for (final entry in profile.entries) {
      if (entry.value != null) {
        cleaned[entry.key] = entry.value;
      }
    }

    await updateValue('finnness/users/$uid/profile', cleaned);

    final current = await fetchProfile(uid);
    await updateCache(uid, 'profile', current?.toJson() ?? cleaned);
  }

  Future<void> updateCache(String uid, String kind, Object? value) {
    return _setCache(cacheKey(uid, kind), value);
  }

  Future<void> _writeNow(PendingWrite write) async {
    try {
      await _applyWrite(write);
    } catch (_) {
      await _queuePending(write);
    }
  }

  Future<void> _applyWrite(PendingWrite write) async {
    final ref = _database.ref(write.path);

    switch (write.operation) {
      case PendingOperation.set:
        await ref.set(write.value).timeout(_networkTimeout);
      case PendingOperation.update:
        await ref
            .update(Map<String, Object?>.from(write.value as Map))
            .timeout(_networkTimeout);
      case PendingOperation.remove:
        await ref.remove().timeout(_networkTimeout);
    }
  }

  Future<void> _queuePending(PendingWrite write) async {
    final list = await _loadPending();
    list.add(write);
    await _savePending(list);
  }

  Future<List<PendingWrite>> _loadPending() async {
    final data = await _readCacheStore();
    final raw = data[_pendingKey];
    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((item) => PendingWrite.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _savePending(List<PendingWrite> list) async {
    final data = await _readCacheStore();
    data[_pendingKey] = list.map((write) => write.toJson()).toList();
    await _writeCacheStore(data);
  }

  Future<Object?> _getCache(String key) async {
    final data = await _readCacheStore();
    return data[key];
  }

  Future<void> _setCache(String key, Object? value) async {
    final data = await _readCacheStore();
    data[key] = value;
    await _writeCacheStore(data);
  }

  Future<Map<String, dynamic>> _readCacheStore() async {
    return readCache();
  }

  Future<void> _writeCacheStore(Map<String, dynamic> data) async {
    await writeCache(data);
  }
}

enum PendingOperation { set, update, remove }

class PendingWrite {
  const PendingWrite({required this.path, required this.operation, this.value});

  final String path;
  final PendingOperation operation;
  final Object? value;

  factory PendingWrite.fromJson(Map<String, dynamic> json) {
    return PendingWrite(
      path: json['path'] as String,
      operation: PendingOperation.values.byName(json['operation'] as String),
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'path': path, 'operation': operation.name, 'value': value};
  }
}

Map<String, dynamic> asStringMap(Object? value) => _asStringMap(value);

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return {};
}
