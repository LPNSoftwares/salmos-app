import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_background.dart';
import '../domain/tts_settings.dart';
import '../tts_service.dart';

class TtsSettingsSection extends ConsumerWidget {
  const TtsSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts = ref.watch(ttsServiceProvider);
    final settings = tts.settings;

    return Column(
      children: [
        SwitchListTile(
          value: settings.autoReadOnOpen,
          onChanged: ref.read(ttsServiceProvider).updateAutoReadOnOpen,
          contentPadding: EdgeInsets.zero,
          title: const Text('Ouvir automaticamente ao abrir um Salmo'),
        ),
        const SizedBox(height: 8),
        if (!tts.hasPtBrVoice) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.softGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.softGold.withValues(alpha: 0.28),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nenhuma voz pt-BR foi encontrada. O app usará uma voz disponível no aparelho.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                title: const Text('Voz'),
                trailing: DropdownButton<TtsVoice?>(
                  value: _selectedVoice(tts.voices, settings),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem<TtsVoice?>(
                      value: null,
                      child: Text('Voz padrão'),
                    ),
                    ...tts.voices.map(
                      (voice) => DropdownMenuItem<TtsVoice?>(
                        value: voice,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 190),
                          child: Text(
                            voice.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: ref.read(ttsServiceProvider).updateVoice,
                ),
              ),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              _SliderRow(
                title: 'Velocidade',
                value: settings.speechRate,
                displayValue: '${settings.speechRate.toStringAsFixed(2)}x',
                min: 0.2,
                max: 1.0,
                onChanged: ref.read(ttsServiceProvider).updateSpeechRate,
              ),
              _SliderRow(
                title: 'Tom',
                value: settings.pitch,
                displayValue: settings.pitch.toStringAsFixed(2),
                min: 0.5,
                max: 2.0,
                onChanged: ref.read(ttsServiceProvider).updatePitch,
              ),
              _SliderRow(
                title: 'Volume',
                value: settings.volume,
                displayValue: '${(settings.volume * 100).round()}%',
                min: 0.0,
                max: 1.0,
                onChanged: ref.read(ttsServiceProvider).updateVolume,
              ),
            ],
          ),
        ),
      ],
    );
  }

  TtsVoice? _selectedVoice(List<TtsVoice> voices, TtsSettings settings) {
    final selected = settings.selectedVoice;
    if (selected == null) {
      return null;
    }
    for (final voice in voices) {
      if (voice.name == selected.name && voice.locale == selected.locale) {
        return voice;
      }
    }
    return null;
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.title,
    required this.value,
    required this.displayValue,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final double value;
  final String displayValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Row(
        children: [
          SizedBox(width: 94, child: Text(title)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.softGold,
                thumbColor: const Color(0xFFFFF6E8),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: 16,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(displayValue, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
