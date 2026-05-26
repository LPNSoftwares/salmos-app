import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';

class AppSettings {
  const AppSettings({
    required this.notificationsEnabled,
    required this.notificationTimes,
    required this.bibleVersion,
    required this.themeMode,
    required this.readingFontScale,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      notificationsEnabled: true,
      notificationTimes: [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 12, minute: 0),
        TimeOfDay(hour: 19, minute: 0),
      ],
      bibleVersion: ApiConstants.defaultVersion,
      themeMode: ThemeMode.system,
      readingFontScale: 1.0,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawTimes = json['notificationTimes'] as List<dynamic>? ?? [];
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notificationTimes:
          rawTimes
              .map((item) => item as Map<String, dynamic>)
              .map(
                (item) => TimeOfDay(
                  hour: item['hour'] as int? ?? 8,
                  minute: item['minute'] as int? ?? 0,
                ),
              )
              .toList()
            ..sort(
              (a, b) => a.hour == b.hour
                  ? a.minute.compareTo(b.minute)
                  : a.hour.compareTo(b.hour),
            ),
      bibleVersion:
          (json['bibleVersion'] as String? ?? ApiConstants.defaultVersion)
              .toLowerCase(),
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      readingFontScale: (json['readingFontScale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  final bool notificationsEnabled;
  final List<TimeOfDay> notificationTimes;
  final String bibleVersion;
  final ThemeMode themeMode;
  final double readingFontScale;

  AppSettings copyWith({
    bool? notificationsEnabled,
    List<TimeOfDay>? notificationTimes,
    String? bibleVersion,
    ThemeMode? themeMode,
    double? readingFontScale,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTimes: notificationTimes ?? this.notificationTimes,
      bibleVersion: bibleVersion ?? this.bibleVersion,
      themeMode: themeMode ?? this.themeMode,
      readingFontScale: readingFontScale ?? this.readingFontScale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'notificationTimes': notificationTimes
          .map((time) => {'hour': time.hour, 'minute': time.minute})
          .toList(),
      'bibleVersion': bibleVersion,
      'themeMode': themeMode.name,
      'readingFontScale': readingFontScale,
    };
  }
}
