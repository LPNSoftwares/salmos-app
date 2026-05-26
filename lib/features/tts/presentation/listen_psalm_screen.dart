import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_footer_nav.dart';
import '../../psalm/presentation/app_controller.dart';
import '../domain/tts_settings.dart';
import '../tts_service.dart';

class ListenPsalmScreen extends ConsumerStatefulWidget {
  const ListenPsalmScreen({super.key});

  @override
  ConsumerState<ListenPsalmScreen> createState() => _ListenPsalmScreenState();
}

class _ListenPsalmScreenState extends ConsumerState<ListenPsalmScreen> {
  Timer? _ticker;
  String? _startedPsalmId;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCurrentPsalm());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    final tts = ref.watch(ttsServiceProvider);
    final psalm = app.currentPsalm;
    final position = tts.estimatedPosition;
    final duration = tts.estimatedDuration;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: const AppFooterNav(
        current: AppFooterDestination.home,
      ),
      body: AppBackground(
        child: SafeArea(
          child: psalm == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  children: [
                    _Header(onSettings: () => context.go('/settings')),
                    const SizedBox(height: 8),
                    Text(
                      'Ouça a Palavra de Deus\nem voz alta e deixe que ela toque seu coração.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _AudioBadge(),
                    const SizedBox(height: 10),
                    Center(
                      child: Chip(
                        avatar: const Icon(Icons.menu_book_rounded, size: 18),
                        label: Text(psalm.reference),
                        side: const BorderSide(color: AppTheme.softGold),
                        backgroundColor: Colors.transparent,
                        labelStyle: const TextStyle(
                          color: AppTheme.softGold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '“${psalm.text}”',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        height: 1.22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ProgressRow(
                      position: position,
                      duration: duration,
                      progress: progress,
                    ),
                    const SizedBox(height: 8),
                    _PlayerControls(
                      isLoading: tts.playbackState == TtsPlaybackState.loading,
                      isSpeaking:
                          tts.playbackState == TtsPlaybackState.speaking,
                      onBack: () => ref.read(ttsServiceProvider).replay(),
                      onToggle: () =>
                          ref.read(ttsServiceProvider).toggle(psalm),
                      onNext: () async {
                        await ref.read(ttsServiceProvider).stop();
                        await ref.read(appControllerProvider).fetchNewPsalm();
                        final next = ref
                            .read(appControllerProvider)
                            .currentPsalm;
                        if (next != null) {
                          await ref.read(ttsServiceProvider).speakPsalm(next);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    const _VoiceSummary(),
                    if (tts.playbackState == TtsPlaybackState.error &&
                        tts.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _ErrorNotice(message: tts.errorMessage!),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _startCurrentPsalm() async {
    final psalm = ref.read(appControllerProvider).currentPsalm;
    if (psalm == null || _startedPsalmId == psalm.id) {
      return;
    }
    _startedPsalmId = psalm.id;
    await ref.read(ttsServiceProvider).speakPsalm(psalm);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Text(
          'Ouça os Salmos',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_rounded),
          ),
        ),
      ],
    );
  }
}

class _AudioBadge extends StatelessWidget {
  const _AudioBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 168,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(46),
          boxShadow: [
            BoxShadow(
              color: AppTheme.softGold.withValues(alpha: 0.24),
              blurRadius: 38,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(46),
          child: Image.asset(
            'assets/branding/audio_badge.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.position,
    required this.duration,
    required this.progress,
  });

  final Duration position;
  final Duration duration;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(_format(position)),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.softGold,
              thumbColor: AppTheme.softGold,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.28),
            ),
            child: Slider(value: progress, onChanged: (_) {}),
          ),
        ),
        Text(_format(duration)),
      ],
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.isLoading,
    required this.isSpeaking,
    required this.onBack,
    required this.onToggle,
    required this.onNext,
  });

  final bool isLoading;
  final bool isSpeaking;
  final VoidCallback onBack;
  final VoidCallback onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onBack,
          iconSize: 42,
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        const SizedBox(width: 22),
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.softGold, width: 2),
          ),
          child: IconButton(
            onPressed: onToggle,
            iconSize: 48,
            icon: isLoading
                ? const CircularProgressIndicator()
                : Icon(
                    isSpeaking ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
          ),
        ),
        const SizedBox(width: 22),
        IconButton(
          onPressed: onNext,
          iconSize: 42,
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }
}

class _VoiceSummary extends ConsumerWidget {
  const _VoiceSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts = ref.watch(ttsServiceProvider);
    final settings = tts.settings;
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            icon: Icons.mic_none_rounded,
            title: 'Voz',
            value: settings.selectedVoiceName ?? 'Voz 1',
            onTap: () async {
              await ref.read(ttsServiceProvider).stop();
              if (context.mounted) {
                _showVoicePicker(context, ref);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            icon: Icons.speed_rounded,
            title: 'Velocidade',
            value: '${settings.speechRate.toStringAsFixed(2)}x',
            onTap: () async {
              await ref.read(ttsServiceProvider).stop();
              if (context.mounted) {
                _showSliderSheet(
                  context: context,
                  title: 'Velocidade',
                  value: settings.speechRate,
                  min: 0.2,
                  max: 1.0,
                  display: (value) => '${value.toStringAsFixed(2)}x',
                  onChanged: ref.read(ttsServiceProvider).updateSpeechRate,
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            icon: Icons.tune_rounded,
            title: 'Tom',
            value: settings.pitch.toStringAsFixed(2),
            onTap: () async {
              await ref.read(ttsServiceProvider).stop();
              if (context.mounted) {
                _showSliderSheet(
                  context: context,
                  title: 'Tom',
                  value: settings.pitch,
                  min: 0.5,
                  max: 2.0,
                  display: (value) => value.toStringAsFixed(2),
                  onChanged: ref.read(ttsServiceProvider).updatePitch,
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            icon: Icons.volume_up_rounded,
            title: 'Volume',
            value: '${(settings.volume * 100).round()}%',
            onTap: () async {
              await ref.read(ttsServiceProvider).stop();
              if (context.mounted) {
                _showSliderSheet(
                  context: context,
                  title: 'Volume',
                  value: settings.volume,
                  min: 0,
                  max: 1,
                  display: (value) => '${(value * 100).round()}%',
                  onChanged: ref.read(ttsServiceProvider).updateVolume,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _showVoicePicker(BuildContext context, WidgetRef ref) {
    final tts = ref.read(ttsServiceProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF061B33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            children: [
              Text(
                'Escolha a voz',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Voz padrão do aparelho'),
                trailing: tts.settings.selectedVoice == null
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  ref.read(ttsServiceProvider).updateVoice(null);
                  Navigator.of(context).pop();
                },
              ),
              for (final voice in tts.voices)
                ListTile(
                  title: Text(voice.name),
                  subtitle: Text(voice.locale),
                  trailing:
                      tts.settings.selectedVoiceName == voice.name &&
                          tts.settings.selectedVoiceLocale == voice.locale
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    ref.read(ttsServiceProvider).updateVoice(voice);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSliderSheet({
    required BuildContext context,
    required String title,
    required double value,
    required double min,
    required double max,
    required String Function(double value) display,
    required ValueChanged<double> onChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF061B33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        var current = value;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        display(current),
                        style: const TextStyle(
                          color: AppTheme.softGold,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.softGold,
                        thumbColor: AppTheme.softGold,
                        inactiveTrackColor: Colors.white.withValues(
                          alpha: 0.22,
                        ),
                      ),
                      child: Slider(
                        value: current,
                        min: min,
                        max: max,
                        divisions: 20,
                        onChanged: (next) {
                          setSheetState(() => current = next);
                          onChanged(next);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: Material(
        color: const Color(0xFF072445).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(icon, size: 30)],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
