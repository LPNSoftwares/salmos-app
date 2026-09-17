import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../notifications/notification_service.dart';
import '../../settings/app_settings.dart';

import '../data/psalm_repository.dart';
import '../domain/psalm.dart';

final appControllerProvider = ChangeNotifierProvider<AppController>((ref) {
  return AppController(
    repository: ref.watch(psalmRepositoryProvider),
    storage: ref.watch(localStorageProvider),
    notifications: ref.watch(notificationServiceProvider),
  );
});

class AppController extends ChangeNotifier {
  AppController({
    required PsalmRepository repository,
    required LocalStorageService storage,
    required NotificationService notifications,
  }) : _repository = repository,
       _storage = storage,
       _notifications = notifications {
    _notificationSub = _notifications.payloads.listen(_openNotificationPsalm);
  }

  final PsalmRepository _repository;
  final LocalStorageService _storage;
  final NotificationService _notifications;
  late final StreamSubscription<String> _notificationSub;

  Psalm? currentPsalm;
  List<Psalm> favorites = [];
  List<Psalm> history = [];
  List<Psalm> cache = [];
  AppSettings settings = AppSettings.defaults();
  bool isLoading = true;
  bool isRefreshing = false;
  bool isSearchingChapter = false;
  String? message;
  bool openedFromNotification = false;

  Stream<String> get notificationPayloads => _notifications.payloads;

  bool get hasCurrentFavorite =>
      currentPsalm != null &&
      favorites.any((item) => item.id == currentPsalm!.id);

  List<BibleBook> get books => _repository.books;
  Psalm? dailyPassage;
  int get verseCount => _repository.verseCount;
  int get chapterCount => _repository.chapterCount;
  List<Psalm> search(String query) => _repository.search(query);

  Future<void> initialize() async {
    isLoading = true;
    message = null;
    notifyListeners();
    try {
      settings = _storage.getSettings().copyWith(bibleVersion: 'vfl');
      favorites = _storage.getFavorites();
      history = _storage.getHistory();
      await _repository.initialize();
      dailyPassage = await _repository.dailyVerse();
      currentPsalm = _storage.getLastPsalm() ?? dailyPassage;
      cache = [];
      for (var i = 0; i < 8; i++) {
        cache.add(await _repository.fetchRandomPsalm('vfl'));
      }
      await _storage.saveSettings(settings);
      final launchPayload = _notifications.consumeLaunchPayload();
      if (launchPayload != null && launchPayload.isNotEmpty) {
        openedFromNotification = true;
        await _openNotificationPsalm(launchPayload);
      }
      await _scheduleNotifications();
    } on AppException catch (error) {
      message = error.message;
    } catch (_) {
      message = 'Não foi possível carregar os dados locais. Tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewPsalm({bool showFallbackMessage = true}) =>
      randomPassage(psalmsOnly: true);

  Future<void> randomPassage({bool psalmsOnly = false}) async {
    if (isRefreshing) return;
    isRefreshing = true;
    message = null;
    notifyListeners();
    try {
      await _selectPsalm(await _repository.randomVerse(psalmsOnly: psalmsOnly));
    } on AppException catch (error) {
      message = error.message;
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> openChapter(String abbrev, int chapter) async {
    try {
      await _selectPsalm(await _repository.readChapter(abbrev, chapter));
      return true;
    } on AppException catch (error) {
      message = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchPsalmChapter(int chapter) async {
    isSearchingChapter = true;
    message = null;
    notifyListeners();

    try {
      final psalm = await _repository.fetchPsalmChapter(
        version: settings.bibleVersion,
        chapter: chapter,
      );
      await _selectPsalm(psalm);
      return true;
    } on AppException catch (error) {
      message = error.message;
      return false;
    } finally {
      isSearchingChapter = false;
      notifyListeners();
    }
  }

  Future<void> showPsalm(Psalm psalm) => _selectPsalm(psalm.copyWith());

  Future<void> toggleFavorite() async {
    final psalm = currentPsalm;
    if (psalm == null) {
      return;
    }
    if (favorites.any((item) => item.id == psalm.id)) {
      favorites = favorites.where((item) => item.id != psalm.id).toList();
    } else {
      favorites = [psalm, ...favorites];
    }
    await _storage.saveFavorites(favorites);
    notifyListeners();
  }

  Future<void> shareCurrentPsalm() async {
    final psalm = currentPsalm;
    if (psalm == null) {
      return;
    }
    await SharePlus.instance.share(ShareParams(text: psalm.shareText));
  }

  Future<void> clearHistory() async {
    history = [];
    await _storage.saveHistory(history);
    notifyListeners();
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    settings = settings.copyWith(notificationsEnabled: enabled);
    await _persistSettingsAndReschedule(reschedule: true);
  }

  Future<void> updateNotificationTime(int index, TimeOfDay time) async {
    final times = [...settings.notificationTimes];
    times[index] = time;
    settings = settings.copyWith(notificationTimes: times);
    await _persistSettingsAndReschedule(reschedule: true);
  }

  Future<void> updateBibleVersion(String version) async {
    settings = settings.copyWith(bibleVersion: version.toLowerCase().trim());
    await _persistSettingsAndReschedule();
    await fetchNewPsalm();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    settings = settings.copyWith(themeMode: mode);
    await _persistSettingsAndReschedule();
  }

  Future<void> updateReadingFontScale(double value) async {
    settings = settings.copyWith(readingFontScale: value.clamp(0.82, 1.35));
    await _persistSettingsAndReschedule();
  }

  Future<void> increaseReadingFont() {
    return updateReadingFontScale(settings.readingFontScale + 0.08);
  }

  Future<void> decreaseReadingFont() {
    return updateReadingFontScale(settings.readingFontScale - 0.08);
  }

  Future<void> _selectPsalm(Psalm psalm) async {
    currentPsalm = psalm.copyWith(receivedAt: DateTime.now());
    history = [
      currentPsalm!,
      ...history.where((item) => item.id != currentPsalm!.id),
    ].take(50).toList();
    cache = [
      currentPsalm!,
      ...cache.where((item) => item.id != currentPsalm!.id),
    ].take(20).toList();
    await _storage.saveLastPsalm(currentPsalm!);
    await _storage.saveHistory(history);
    await _storage.savePsalmCache(cache);
    notifyListeners();
  }

  Future<void> _persistSettingsAndReschedule({bool reschedule = false}) async {
    await _storage.saveSettings(settings);
    if (reschedule) await _scheduleNotifications();
    notifyListeners();
  }

  Future<void> _scheduleNotifications() async {
    try {
      await _notifications.scheduleDailyPsalms(
        settings: settings,
        cache: cache,
      );
    } catch (_) {
      // A denied notification permission must never prevent offline reading.
    }
  }

  Future<void> _openNotificationPsalm(String payload) async {
    try {
      final psalm = Psalm.fromJson(jsonDecode(payload) as Map<String, dynamic>);
      await _selectPsalm(psalm);
    } catch (_) {
      message = AppStrings.notificationFallbackBody;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notificationSub.cancel();
    super.dispose();
  }
}
