import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/psalm/domain/psalm.dart';
import '../../features/settings/app_settings.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService deve ser sobrescrito no main.');
});

class LocalStorageService {
  LocalStorageService(this._prefs);

  static Future<LocalStorageService> create() async {
    return LocalStorageService(await SharedPreferences.getInstance());
  }

  final SharedPreferences _prefs;

  static const _lastPsalmKey = 'last_psalm';
  static const _favoritesKey = 'favorites';
  static const _historyKey = 'history';
  static const _cacheKey = 'psalm_cache';
  static const _settingsKey = 'settings';
  static const _requestLogKey = 'request_log';

  Psalm? getLastPsalm() => _readPsalm(_lastPsalmKey);

  Future<void> saveLastPsalm(Psalm psalm) {
    return _prefs.setString(_lastPsalmKey, psalm.encode());
  }

  List<Psalm> getFavorites() => _readPsalmList(_favoritesKey);

  Future<void> saveFavorites(List<Psalm> psalms) {
    return _writePsalmList(_favoritesKey, psalms);
  }

  List<Psalm> getHistory() => _readPsalmList(_historyKey);

  Future<void> saveHistory(List<Psalm> psalms) {
    return _writePsalmList(_historyKey, psalms.take(50).toList());
  }

  List<Psalm> getPsalmCache() => _readPsalmList(_cacheKey);

  Future<void> savePsalmCache(List<Psalm> psalms) {
    return _writePsalmList(_cacheKey, psalms.take(20).toList());
  }

  AppSettings getSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) {
      return AppSettings.defaults();
    }
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) {
    return _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  List<DateTime> getRequestLog() {
    final raw = _prefs.getStringList(_requestLogKey) ?? [];
    return raw.map(DateTime.parse).toList();
  }

  Future<void> saveRequestLog(List<DateTime> log) {
    return _prefs.setStringList(
      _requestLogKey,
      log.map((date) => date.toIso8601String()).toList(),
    );
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Psalm? _readPsalm(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) {
      return null;
    }
    return Psalm.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<Psalm> _readPsalmList(String key) {
    final raw = _prefs.getStringList(key) ?? [];
    return raw
        .map((item) => Psalm.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writePsalmList(String key, List<Psalm> psalms) {
    return _prefs.setStringList(
      key,
      psalms.map((psalm) => psalm.encode()).toList(),
    );
  }
}
