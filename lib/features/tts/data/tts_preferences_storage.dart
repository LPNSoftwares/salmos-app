import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/local_storage_service.dart';
import '../domain/tts_settings.dart';

final ttsPreferencesStorageProvider = Provider<TtsPreferencesStorage>((ref) {
  return TtsPreferencesStorage(ref.watch(localStorageProvider));
});

class TtsPreferencesStorage {
  const TtsPreferencesStorage(this._storage);

  static const _key = 'tts_settings';

  final LocalStorageService _storage;

  TtsSettings load() {
    final raw = _storage.getString(_key);
    if (raw == null) {
      return TtsSettings.defaults();
    }
    return TtsSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(TtsSettings settings) {
    return _storage.setString(_key, jsonEncode(settings.toJson()));
  }
}
