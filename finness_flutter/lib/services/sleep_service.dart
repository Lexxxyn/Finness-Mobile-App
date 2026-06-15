import '../models/models.dart' hide asStringMap;
import 'firebase_service.dart';
import 'sqlite_service.dart';

export '../models/models.dart' show Sleep;

class SleepService {
  SleepService({FirebaseService? firebaseService, SqliteService? sqliteService})
    : _firebase = firebaseService ?? FirebaseService.instance,
      _sqlite = sqliteService ?? SqliteService.instance;

  final FirebaseService _firebase;
  final SqliteService _sqlite;

  Future<Sleep?> fetchSleepForDate(String uid, String date) async {
    final sleep = await _firebase.cachedFetch<Sleep>(
      uid: uid,
      kind: 'sleep:$date',
      path: 'finnness/users/$uid/sleep/$date',
      fromValue: (value) => Sleep.fromJson(asStringMap(value)),
    );

    if (sleep == null) return _sqlite.fetchSleepForDate(uid, date);

    await _sqlite.saveSleep(uid, sleep);
    return sleep;
  }

  Future<Map<String, Sleep>?> fetchAllSleep(String uid) async {
    final data = await _firebase.cachedFetch<Map<String, dynamic>>(
      uid: uid,
      kind: 'sleep_all',
      path: 'finnness/users/$uid/sleep',
      fromValue: asStringMap,
    );

    if (data == null) {
      final local = await _sqlite.fetchAllSleep(uid);
      return local.isEmpty ? null : local;
    }

    final sleepByDate = data.map(
      (date, value) => MapEntry(date, Sleep.fromJson(asStringMap(value))),
    );

    for (final entry in sleepByDate.entries) {
      await _sqlite.saveSleep(uid, entry.value);
      await _firebase.updateCache(
        uid,
        'sleep:${entry.key}',
        entry.value.toJson(),
      );
    }

    return sleepByDate;
  }

  Future<void> saveSleep(String uid, Sleep sleep) async {
    await _sqlite.saveSleep(uid, sleep);

    await _firebase.setValue(
      'finnness/users/$uid/sleep/${sleep.date}',
      sleep.toJson(),
    );

    await _firebase.updateCache(uid, 'sleep:${sleep.date}', sleep.toJson());

    final all = await fetchAllSleep(uid) ?? <String, Sleep>{};
    final map = <String, Object?>{};
    for (final entry in all.entries) {
      map[entry.key] = entry.value.toJson();
    }
    map[sleep.date] = sleep.toJson();
    await _firebase.updateCache(uid, 'sleep_all', map);
  }
}
