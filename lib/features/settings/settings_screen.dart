import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bible/bible_screens.dart';
import '../psalm/presentation/app_controller.dart';
import '../tts/presentation/tts_settings_screen.dart';
import '../../shared/widgets/app_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appControllerProvider);
    final settings = app.settings;
    return BibleShell(
      title: 'Do seu jeito',
      subtitle: 'Preferências de leitura',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.offline_pin_outlined, size: 32),
                const SizedBox(height: 12),
                Text(
                  'Sua Bíblia está aqui',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'VFL • ${app.books.length} livros • ${app.chapterCount} capítulos\nDisponível sem internet.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Aparência', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in {
                      ThemeMode.system: 'Sistema',
                      ThemeMode.light: 'Claro',
                      ThemeMode.dark: 'Escuro',
                    }.entries)
                      ChoiceChip(
                        label: Text(entry.value),
                        selected: settings.themeMode == entry.key,
                        onSelected: (_) => app.updateThemeMode(entry.key),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Tamanho do texto • ${(settings.readingFontScale * 100).round()}%',
                ),
                Slider(
                  value: settings.readingFontScale,
                  min: .82,
                  max: 1.35,
                  onChanged: app.updateReadingFontScale,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Lembretes de paz',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.notificationsEnabled,
                  onChanged: app.updateNotificationsEnabled,
                  title: const Text('Receber notificações'),
                  subtitle: const Text(
                    'Lembretes locais nos horários escolhidos.',
                  ),
                ),
                for (var i = 0; i < settings.notificationTimes.length; i++)
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(settings.notificationTimes[i].format(context)),
                    trailing: const Icon(Icons.edit_outlined),
                    enabled: settings.notificationsEnabled,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: settings.notificationTimes[i],
                      );
                      if (time != null) {
                        await app.updateNotificationTime(i, time);
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Leitura em voz alta',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text('Usa uma voz offline instalada no aparelho.'),
          const SizedBox(height: 12),
          const TtsSettingsSection(),
        ],
      ),
    );
  }
}
