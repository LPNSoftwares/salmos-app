class TtsVoice {
  const TtsVoice({required this.name, required this.locale});

  factory TtsVoice.fromJson(Map<String, dynamic> json) {
    return TtsVoice(
      name: json['name'] as String? ?? '',
      locale: json['locale'] as String? ?? '',
    );
  }

  final String name;
  final String locale;

  String get label => locale.isEmpty ? name : '$name ($locale)';

  Map<String, dynamic> toJson() => {'name': name, 'locale': locale};

  Map<String, String> toTtsMap() => {'name': name, 'locale': locale};
}

class TtsSettings {
  const TtsSettings({
    required this.selectedVoiceName,
    required this.selectedVoiceLocale,
    required this.speechRate,
    required this.pitch,
    required this.volume,
    required this.language,
    required this.autoReadOnOpen,
  });

  factory TtsSettings.defaults() {
    return const TtsSettings(
      selectedVoiceName: null,
      selectedVoiceLocale: null,
      speechRate: 0.45,
      pitch: 1.0,
      volume: 1.0,
      language: 'pt-BR',
      autoReadOnOpen: false,
    );
  }

  factory TtsSettings.fromJson(Map<String, dynamic> json) {
    return TtsSettings(
      selectedVoiceName: json['selectedVoiceName'] as String?,
      selectedVoiceLocale: json['selectedVoiceLocale'] as String?,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.45,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      language: json['language'] as String? ?? 'pt-BR',
      autoReadOnOpen: json['autoReadOnOpen'] as bool? ?? false,
    );
  }

  final String? selectedVoiceName;
  final String? selectedVoiceLocale;
  final double speechRate;
  final double pitch;
  final double volume;
  final String language;
  final bool autoReadOnOpen;

  TtsVoice? get selectedVoice {
    if (selectedVoiceName == null || selectedVoiceLocale == null) {
      return null;
    }
    return TtsVoice(name: selectedVoiceName!, locale: selectedVoiceLocale!);
  }

  TtsSettings copyWith({
    String? selectedVoiceName,
    String? selectedVoiceLocale,
    bool clearVoice = false,
    double? speechRate,
    double? pitch,
    double? volume,
    String? language,
    bool? autoReadOnOpen,
  }) {
    return TtsSettings(
      selectedVoiceName: clearVoice
          ? null
          : selectedVoiceName ?? this.selectedVoiceName,
      selectedVoiceLocale: clearVoice
          ? null
          : selectedVoiceLocale ?? this.selectedVoiceLocale,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      language: language ?? this.language,
      autoReadOnOpen: autoReadOnOpen ?? this.autoReadOnOpen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedVoiceName': selectedVoiceName,
      'selectedVoiceLocale': selectedVoiceLocale,
      'speechRate': speechRate,
      'pitch': pitch,
      'volume': volume,
      'language': language,
      'autoReadOnOpen': autoReadOnOpen,
    };
  }
}

enum TtsPlaybackState { idle, loading, speaking, stopped, error }
