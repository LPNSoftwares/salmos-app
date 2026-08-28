import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_footer_nav.dart';
import '../psalm/presentation/app_controller.dart';
import '../tts/presentation/tts_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const versions = ApiConstants.supportedVersions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final settings = controller.settings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: const AppFooterNav(
        current: AppFooterDestination.settings,
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              const _SettingsHeader(),
              const SizedBox(height: 24),
              _SectionHeader(
                icon: Icons.notifications_active_rounded,
                title: 'Notificações',
              ),
              const SizedBox(height: 12),
              _NotificationToggle(
                enabled: settings.notificationsEnabled,
                onChanged: controller.updateNotificationsEnabled,
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                icon: Icons.schedule_rounded,
                title: 'Horários das notificações',
              ),
              const SizedBox(height: 12),
              _SettingsPanel(
                children: [
                  for (
                    var index = 0;
                    index < settings.notificationTimes.length;
                    index++
                  )
                    _TimeRow(
                      icon: index == 2
                          ? Icons.nightlight_round
                          : Icons.wb_sunny_rounded,
                      title: settings.notificationTimes[index].format(context),
                      subtitle: switch (index) {
                        0 => 'Manhã',
                        1 => 'Meio-dia',
                        _ => 'Noite',
                      },
                      enabled: settings.notificationsEnabled,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: settings.notificationTimes[index],
                        );
                        if (picked != null) {
                          await controller.updateNotificationTime(
                            index,
                            picked,
                          );
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionHeader(
                icon: Icons.volume_up_rounded,
                title: 'Leitura em voz',
              ),
              const SizedBox(height: 12),
              const TtsSettingsSection(),
              const SizedBox(height: 24),
              const _SectionHeader(
                icon: Icons.settings_rounded,
                title: 'Outras configurações',
              ),
              const SizedBox(height: 12),
              _SettingsPanel(
                children: [
                  _ChoiceRow(
                    icon: Icons.palette_rounded,
                    title: 'Tema do aplicativo',
                    value: _themeLabel(settings.themeMode),
                    trailing: DropdownButton<ThemeMode>(
                      value: settings.themeMode,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(AppStrings.system),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(AppStrings.light),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(AppStrings.dark),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateThemeMode(value);
                        }
                      },
                    ),
                  ),
                  _ChoiceRow(
                    icon: Icons.bookmark_rounded,
                    title: 'Versão da Bíblia',
                    value: settings.bibleVersion.toUpperCase(),
                    trailing: DropdownButton<String>(
                      value: versions.contains(settings.bibleVersion)
                          ? settings.bibleVersion
                          : 'nvi',
                      underline: const SizedBox.shrink(),
                      items: versions
                          .map(
                            (version) => DropdownMenuItem(
                              value: version,
                              child: Text(version.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateBibleVersion(value);
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.format_size_rounded),
                    title: Row(
                      children: [
                        const Expanded(child: Text('Tamanho da letra')),
                        Text('${(settings.readingFontScale * 100).round()}%'),
                      ],
                    ),
                    subtitle: Slider(
                      value: settings.readingFontScale,
                      min: 0.82,
                      max: 1.35,
                      divisions: 10,
                      onChanged: controller.updateReadingFontScale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'Escuro',
      ThemeMode.light => 'Claro',
      ThemeMode.system => 'Padrão do sistema',
    };
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Column(
          children: [
            Text(
              'Configurações',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Container(
              width: 56,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.softGold,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: AppTheme.softGold.withValues(alpha: 0.38),
            ),
          ),
          child: Icon(icon),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          value: enabled,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          title: const Text('Ativar notificações'),
          subtitle: const Text('Receba Salmos em horários especiais.'),
        ),
        Divider(color: Colors.white.withValues(alpha: 0.14)),
      ],
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          ],
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String value;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: trailing,
    );
  }
}
