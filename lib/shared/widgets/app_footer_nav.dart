import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../features/psalm/presentation/app_controller.dart';
import '../../features/tts/tts_service.dart';

enum AppFooterDestination { home, favorites, search, settings, history }

class AppFooterNav extends ConsumerWidget {
  const AppFooterNav({super.key, this.current});

  final AppFooterDestination? current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0B1830).withValues(alpha: 0.98)
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.98),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FooterButton(
              icon: Icons.home,
              label: 'Salmos',
              selected: current == AppFooterDestination.home,
              onTap: () async {
                context.go('/');
              },
            ),
            _FooterButton(
              icon: Icons.favorite_rounded,
              label: 'Favoritos',
              selected: current == AppFooterDestination.favorites,
              onTap: () => context.go('/favorites'),
            ),
            _FooterButton(
              icon: Icons.search_rounded,
              label: 'Pesquisar',
              selected: current == AppFooterDestination.search,
              onTap: () => _showPsalmSearch(context, ref),
            ),
            _FooterButton(
              icon: Icons.history_rounded,
              label: 'Histórico',
              selected: current == AppFooterDestination.history,
              onTap: () => context.go('/history'),
            ),
            _FooterButton(
              icon: Icons.settings_rounded,
              label: 'Configurar',
              selected: current == AppFooterDestination.settings,
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? selected
              ? Theme.of(context).colorScheme.secondary
              : Colors.white.withValues(alpha: 0.78)
        : AppTheme.royalBlue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPsalmSearch(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF061B33),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) => _PsalmSearchSheet(ref: ref),
  );
}

class _PsalmSearchSheet extends StatefulWidget {
  const _PsalmSearchSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_PsalmSearchSheet> createState() => _PsalmSearchSheetState();
}

class _PsalmSearchSheetState extends State<_PsalmSearchSheet> {
  final _textController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _loading
            ? const SizedBox(
                key: ValueKey('loading'),
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              )
            : Padding(
                key: const ValueKey('form'),
                padding: EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  MediaQuery.of(context).viewInsets.bottom + 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Pesquisar Salmo',
                          hintText: 'Digite 1 a 150',
                          prefixIcon: Icon(Icons.search_rounded),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _loading ? null : _search,
                      child: const Text('Ver'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _search() async {
    final chapter = int.tryParse(_textController.text.trim());
    if (chapter == null || chapter < 1 || chapter > 150 || _loading) {
      return;
    }
    setState(() => _loading = true);

    final tts = widget.ref.read(ttsServiceProvider);
    final app = widget.ref.read(appControllerProvider);
    await tts.stop();
    final success = await app
        .fetchPsalmChapter(chapter)
        .timeout(const Duration(seconds: 5), onTimeout: () => false);

    if (!mounted) {
      return;
    }
    context.go('/');
    Navigator.of(context).pop();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            app.message ??
                'Não foi possível carregar o Salmo. O Salmo anterior foi mantido.',
          ),
        ),
      );
    }
  }
}
