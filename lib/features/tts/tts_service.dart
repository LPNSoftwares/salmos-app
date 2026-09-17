import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../psalm/domain/psalm.dart';
import 'data/tts_preferences_storage.dart';
import 'domain/tts_settings.dart';

final ttsServiceProvider = ChangeNotifierProvider<TtsService>((ref) {
  return TtsService(ref.watch(ttsPreferencesStorageProvider))..initialize();
});

class TtsService extends ChangeNotifier {
  TtsService(this._storage);

  final TtsPreferencesStorage _storage;
  final FlutterTts _tts = FlutterTts();

  TtsSettings settings = TtsSettings.defaults();
  TtsPlaybackState playbackState = TtsPlaybackState.idle;
  List<TtsVoice> voices = [];
  String? errorMessage;
  double progress = 0;
  bool hasPtBrVoice = true;
  Future<void>? _initializing;
  int _speechGeneration = 0;
  Psalm? _currentPsalm;
  DateTime? _startedAt;

  bool get isSpeaking => playbackState == TtsPlaybackState.speaking;
  bool get isLoading => playbackState == TtsPlaybackState.loading;

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    settings = _storage.load();
    _bindHandlers();
    try {
      await _loadVoices();
      await _applySettings();
    } catch (_) {
      _setError('Não foi possível preparar a leitura em voz alta.');
    }
    notifyListeners();
  }

  Future<void> speakPsalm(Psalm psalm) async {
    await initialize();
    final generation = ++_speechGeneration;
    playbackState = TtsPlaybackState.loading;
    errorMessage = null;
    progress = 0;
    _currentPsalm = psalm;
    notifyListeners();

    try {
      if (voices.isEmpty) {
        _setError(
          'Nenhuma voz offline instalada. A leitura do texto continua disponível.',
        );
        return;
      }
      await _applySettings();
      final intro = psalm.isFullChapter
          ? '${psalm.bookName} capítulo ${psalm.chapter}.'
          : '${psalm.bookName} capítulo ${psalm.chapter}, versículo ${psalm.number}.';
      final text = '$intro ${psalm.text}';
      // Android engines limit individual utterances. Read long chapters in order.
      var offset = 0;
      while (offset < text.length && generation == _speechGeneration) {
        var end = (offset + 3000).clamp(0, text.length);
        if (end < text.length) {
          final space = text.lastIndexOf(' ', end);
          if (space > offset) end = space;
        }
        final result = await _tts.speak(text.substring(offset, end).trim());
        if (result != 1 || playbackState == TtsPlaybackState.error) {
          _setError('Não foi possível iniciar a leitura neste aparelho.');
          break;
        }
        offset = end;
      }
    } catch (_) {
      _setError('Não foi possível iniciar a leitura do Salmo.');
    }
  }

  Future<void> stop() async {
    _speechGeneration++;
    try {
      await _tts.stop();
      playbackState = TtsPlaybackState.stopped;
      progress = 0;
      notifyListeners();
    } catch (_) {
      _setError('Não foi possível parar a leitura.');
    }
  }

  Future<void> toggle(Psalm psalm) {
    return isSpeaking || isLoading ? stop() : speakPsalm(psalm);
  }

  Future<void> replay() async {
    final psalm = _currentPsalm;
    if (psalm != null) {
      await stop();
      await speakPsalm(psalm);
    }
  }

  Future<void> skipForward() async {
    progress = (progress + 0.12).clamp(0, 1);
    notifyListeners();
  }

  Future<void> skipBack() async {
    progress = (progress - 0.12).clamp(0, 1);
    notifyListeners();
  }

  Duration get estimatedDuration {
    final words = (_currentPsalm?.text.split(RegExp(r'\s+')).length ?? 70)
        .clamp(30, 900);
    final seconds = (words / (2.2 * settings.speechRate.clamp(0.2, 1.0)))
        .round();
    return Duration(seconds: seconds.clamp(45, 600));
  }

  Duration get estimatedPosition {
    if (_startedAt == null || !isSpeaking) {
      return Duration(
        milliseconds: (estimatedDuration.inMilliseconds * progress).round(),
      );
    }
    final elapsed = DateTime.now().difference(_startedAt!);
    final ratio = elapsed.inMilliseconds / estimatedDuration.inMilliseconds;
    progress = ratio.clamp(0, 1);
    return elapsed > estimatedDuration ? estimatedDuration : elapsed;
  }

  Future<void> maybeAutoRead(Psalm psalm) async {
    if (settings.autoReadOnOpen) {
      await speakPsalm(psalm);
    }
  }

  Future<void> updateVoice(TtsVoice? voice) async {
    settings = settings.copyWith(
      selectedVoiceName: voice?.name,
      selectedVoiceLocale: voice?.locale,
      clearVoice: voice == null,
    );
    await _storage.save(settings);
    try {
      await _applySettings();
    } catch (_) {
      _setError('Não foi possível aplicar a voz escolhida.');
    }
    notifyListeners();
  }

  Future<void> updateSpeechRate(double value) =>
      _updateSettings(settings.copyWith(speechRate: value));

  Future<void> updatePitch(double value) =>
      _updateSettings(settings.copyWith(pitch: value));

  Future<void> updateVolume(double value) =>
      _updateSettings(settings.copyWith(volume: value));

  Future<void> updateAutoReadOnOpen(bool value) =>
      _updateSettings(settings.copyWith(autoReadOnOpen: value));

  Future<void> _updateSettings(TtsSettings next) async {
    settings = next;
    await _storage.save(settings);
    try {
      await _applySettings();
    } catch (_) {
      _setError('Não foi possível aplicar as preferências de voz.');
    }
    notifyListeners();
  }

  Future<void> _loadVoices() async {
    try {
      final rawVoices = await _tts.getVoices;
      final parsed = (rawVoices as List<dynamic>)
          .whereType<Map<dynamic, dynamic>>()
          .where(
            (voice) =>
                voice['network_required']?.toString() == '0' &&
                !(voice['features']?.toString() ?? '').contains('notInstalled'),
          )
          .map(
            (voice) => TtsVoice(
              name: (voice['name'] ?? voice['identifier'] ?? '').toString(),
              locale: (voice['locale'] ?? '').toString(),
            ),
          )
          .where((voice) => voice.name.isNotEmpty)
          .toList();

      final ptBr = parsed
          .where(
            (voice) =>
                voice.locale.toLowerCase().replaceAll('_', '-') == 'pt-br',
          )
          .toList();
      hasPtBrVoice = ptBr.isNotEmpty;
      voices = hasPtBrVoice ? ptBr : parsed;

      final selected = settings.selectedVoice;
      if (selected != null &&
          !voices.any(
            (voice) =>
                voice.name == selected.name && voice.locale == selected.locale,
          )) {
        settings = settings.copyWith(clearVoice: true);
        await _storage.save(settings);
      }
    } catch (_) {
      voices = [];
      hasPtBrVoice = false;
      errorMessage = 'Não foi possível listar as vozes deste aparelho.';
    }
  }

  Future<void> _applySettings() async {
    await _tts.setLanguage(settings.language);
    await _tts.setSpeechRate(settings.speechRate);
    await _tts.setPitch(settings.pitch);
    await _tts.setVolume(settings.volume);
    final voice =
        settings.selectedVoice ?? (voices.isEmpty ? null : voices.first);
    if (voice != null) {
      await _tts.setVoice(voice.toTtsMap());
    }
    await _tts.awaitSpeakCompletion(true);
  }

  void _bindHandlers() {
    _tts.setStartHandler(() {
      playbackState = TtsPlaybackState.speaking;
      errorMessage = null;
      _startedAt = DateTime.now();
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      playbackState = TtsPlaybackState.stopped;
      progress = 1;
      _startedAt = null;
      notifyListeners();
    });
    _tts.setCancelHandler(() {
      playbackState = TtsPlaybackState.stopped;
      _startedAt = null;
      notifyListeners();
    });
    _tts.setErrorHandler((message) {
      _setError(message?.toString() ?? 'Falha na leitura em voz alta.');
    });
  }

  void _setError(String message) {
    playbackState = TtsPlaybackState.error;
    errorMessage = message;
    notifyListeners();
  }
}
