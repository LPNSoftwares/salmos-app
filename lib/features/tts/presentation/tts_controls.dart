import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_background.dart';
import '../../psalm/domain/psalm.dart';
import '../domain/tts_settings.dart';
import '../tts_service.dart';

class TtsControls extends ConsumerStatefulWidget {
  const TtsControls({required this.psalm, this.compact = false, super.key});

  final Psalm psalm;
  final bool compact;

  @override
  ConsumerState<TtsControls> createState() => _TtsControlsState();
}

class _TtsControlsState extends ConsumerState<TtsControls>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  String? _lastAutoReadPsalmId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      lowerBound: 0.94,
      upperBound: 1,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoRead());
  }

  @override
  void didUpdateWidget(covariant TtsControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.psalm.id != widget.psalm.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoRead());
    }
  }

  @override
  void dispose() {
    final tts = ref.read(ttsServiceProvider);
    _pulseController.dispose();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tts = ref.watch(ttsServiceProvider);
    final isActive =
        tts.playbackState == TtsPlaybackState.speaking ||
        tts.playbackState == TtsPlaybackState.loading;
    if (tts.playbackState == TtsPlaybackState.error &&
        tts.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(tts.errorMessage!)));
        }
      });
    }

    if (isActive) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 1;
    }

    if (widget.compact) {
      return ScaleTransition(
        scale: _pulseController,
        child: ActionChip(
          avatar: tts.playbackState == TtsPlaybackState.loading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  tts.playbackState == TtsPlaybackState.speaking
                      ? Icons.stop_rounded
                      : Icons.volume_up_rounded,
                  size: 18,
                ),
          label: Text(
            tts.playbackState == TtsPlaybackState.speaking ? 'Parar' : 'Ouvir',
          ),
          onPressed: () => context.go('/listen'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScaleTransition(
          scale: _pulseController,
          child: FilledButton.icon(
            onPressed: () => context.go('/listen'),
            icon: tts.playbackState == TtsPlaybackState.loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    tts.playbackState == TtsPlaybackState.speaking
                        ? Icons.stop_rounded
                        : Icons.volume_up_rounded,
                  ),
            label: Text(
              tts.playbackState == TtsPlaybackState.speaking
                  ? 'Parar'
                  : 'Ouvir Salmo',
            ),
          ),
        ),
        if (tts.playbackState == TtsPlaybackState.error &&
            tts.errorMessage != null) ...[
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.volume_off_rounded,
                  color: Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(tts.errorMessage!)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _maybeAutoRead() async {
    if (!mounted || _lastAutoReadPsalmId == widget.psalm.id) {
      return;
    }
    _lastAutoReadPsalmId = widget.psalm.id;
    await ref.read(ttsServiceProvider).maybeAutoRead(widget.psalm);
  }
}
