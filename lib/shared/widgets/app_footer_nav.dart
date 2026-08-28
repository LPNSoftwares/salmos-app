import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/psalm/presentation/app_controller.dart';
import '../../features/tts/tts_service.dart';

enum AppFooterDestination { home, favorites, search, settings, history }

class AppFooterNav extends ConsumerWidget {
  const AppFooterNav({super.key, this.current});

  final AppFooterDestination? current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = switch (current) {
      AppFooterDestination.home => 0,
      AppFooterDestination.favorites => 1,
      AppFooterDestination.search => 2,
      AppFooterDestination.history => 3,
      AppFooterDestination.settings => 4,
      null => 0,
    };
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 28,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/');
              case 1:
                context.go('/favorites');
              case 2:
                _showPsalmSearch(context, ref);
              case 3:
                context.go('/history');
              case 4:
                context.go('/settings');
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'Salmos',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Pesquisar',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'Histórico',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_rounded),
              selectedIcon: Icon(Icons.tune_rounded),
              label: 'Ajustes',
            ),
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
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encontre um Salmo',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Digite um número entre 1 e 150.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _textController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Número do Salmo',
                        hintText: 'Ex.: 23',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _search,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Abrir Salmo'),
                      ),
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
