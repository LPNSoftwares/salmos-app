import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../psalm/presentation/app_controller.dart';
import '../psalm/domain/psalm.dart';
import '../tts/tts_service.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/psalm_card.dart';
import 'bible_repository.dart';

class BibleShell extends StatelessWidget {
  const BibleShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.selected = 0,
  });
  final String title, subtitle;
  final Widget child;
  final int selected;
  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (i) =>
          context.go(['/', '/bible', '/psalms', '/discover', '/favorites'][i]),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
        NavigationDestination(
          icon: Icon(Icons.menu_book_rounded),
          label: 'Bíblia',
        ),
        NavigationDestination(
          icon: Icon(Icons.wb_sunny_outlined),
          label: 'Salmos',
        ),
        NavigationDestination(
          icon: Icon(Icons.shuffle_rounded),
          label: 'Trechos',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          label: 'Salvos',
        ),
      ],
    ),
    body: AppBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle.toUpperCase(),
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(letterSpacing: 2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Histórico',
                    onPressed: () => context.go('/history'),
                    icon: const Icon(Icons.history),
                  ),
                  IconButton(
                    tooltip: 'Configurações',
                    onPressed: () => context.go('/settings'),
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> openReading(
  BuildContext context,
  WidgetRef ref,
  Psalm passage,
) async {
  await ref.read(ttsServiceProvider).stop();
  await ref.read(appControllerProvider).showPsalm(passage);
  if (context.mounted) context.go('/read');
}

class OfflineHomeScreen extends ConsumerWidget {
  const OfflineHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return BibleShell(
      title: 'Seu momento de paz',
      subtitle: 'Salmos',
      child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                if (state.dailyPassage case final passage?) ...[
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF183F59), Color(0xFF286E75)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF286E75).withValues(alpha: .20),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Color(0xFFFFDA8A)),
                            SizedBox(width: 10),
                            Text(
                              'PALAVRA DO DIA',
                              style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 2,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          passage.text,
                          maxLines: 7,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          passage.reference,
                          style: const TextStyle(
                            color: Color(0xFFFFDA8A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.tonal(
                          onPressed: () => openReading(context, ref, passage),
                          child: const Text('Ler e refletir  →'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (state.message != null) ...[
                  Text(state.message!),
                  TextButton(
                    onPressed: state.initialize,
                    child: const Text('Tentar novamente'),
                  ),
                ],
                Text(
                  'Explore a Palavra',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _ExploreTile(
                  icon: Icons.menu_book_rounded,
                  title: 'Bíblia completa',
                  detail:
                      '${state.books.length} livros • leitura por capítulos',
                  onTap: () => context.go('/bible'),
                ),
                const SizedBox(height: 10),
                _ExploreTile(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Salmos para o seu dia',
                  detail: '150 capítulos de oração e poesia',
                  onTap: () => context.go('/psalms'),
                ),
                const SizedBox(height: 10),
                _ExploreTile(
                  icon: Icons.shuffle,
                  title: 'Deixe a Palavra surpreender',
                  detail: 'Descubra um novo trecho a cada toque',
                  onTap: () => context.go('/discover'),
                ),
                if (state.currentPsalm case final last?) ...[
                  const SizedBox(height: 22),
                  _ExploreTile(
                    icon: Icons.bookmark_outline,
                    title: 'Continuar lendo',
                    detail: last.reference,
                    onTap: () => context.go('/read'),
                  ),
                ],
                const SizedBox(height: 22),
                Text(
                  'Sempre com você. Toda a edição VFL disponível sem internet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String title, detail;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: EdgeInsets.zero,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Icon(icon, size: 28),
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(detail),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class BibleLibraryScreen extends ConsumerStatefulWidget {
  const BibleLibraryScreen({super.key, this.psalmsOnly = false});
  final bool psalmsOnly;
  @override
  ConsumerState<BibleLibraryScreen> createState() => _BibleLibraryState();
}

class _BibleLibraryState extends ConsumerState<BibleLibraryScreen> {
  BibleBook? selected;
  String query = '';
  Timer? debounce;
  List<Psalm> results = [];
  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final book = widget.psalmsOnly && state.books.isNotEmpty
        ? state.books.firstWhere((b) => b.abbrev == 'sl')
        : selected;
    return BibleShell(
      title: book?.name ?? 'Bíblia Sagrada',
      subtitle: widget.psalmsOnly
          ? 'Orações para a vida'
          : 'Edição VFL • offline',
      selected: widget.psalmsOnly ? 2 : 1,
      child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                if (book == null) ...[
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar livros ou palavras na Bíblia',
                    ),
                    onChanged: (value) {
                      debounce?.cancel();
                      debounce = Timer(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          setState(() {
                            query = value;
                            results = state.search(value);
                          });
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  for (final b in state.books.where(
                    (b) => PsalmRepository.normalize(
                      b.name,
                    ).contains(PsalmRepository.normalize(query)),
                  )) ...[
                    _ExploreTile(
                      icon: Icons.menu_book_outlined,
                      title: b.name,
                      detail: '${b.chapters.length} capítulos',
                      onTap: () => setState(() => selected = b),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (query.trim().isNotEmpty) ...[
                    Text(
                      'Trechos encontrados (até 100)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    if (results.isEmpty)
                      const Text(
                        'Nenhum trecho encontrado. Experimente outra palavra.',
                      ),
                    for (final p in results)
                      ListTile(
                        title: Text(p.reference),
                        subtitle: Text(
                          p.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => openReading(context, ref, p),
                      ),
                  ],
                ] else ...[
                  if (!widget.psalmsOnly)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => selected = null),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Todos os livros'),
                      ),
                    ),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 36),
                        const SizedBox(height: 14),
                        Text(
                          'Escolha um capítulo',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${book.chapters.length} capítulos disponíveis no seu aparelho.',
                        ),
                        if (widget.psalmsOnly) ...[
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: () async {
                              await state.randomPassage(psalmsOnly: true);
                              if (context.mounted) context.go('/read');
                            },
                            icon: const Icon(Icons.shuffle),
                            label: const Text('Sortear um Salmo'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (constraints.maxWidth / 72)
                            .floor()
                            .clamp(3, 8),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: book.chapters.length,
                      itemBuilder: (context, index) => OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          await ref.read(ttsServiceProvider).stop();
                          final ok = await state.openChapter(
                            book.abbrev,
                            index + 1,
                          );
                          if (context.mounted && ok) context.go('/read');
                        },
                        child: Text('${index + 1}'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return BibleShell(
      title: 'Uma nova descoberta',
      subtitle: 'Encontre inspiração',
      selected: 3,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              children: [
                const Icon(Icons.auto_awesome, size: 48),
                const SizedBox(height: 20),
                Text(
                  'Abra espaço para uma nova palavra.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Trechos de toda a Bíblia, sorteados sem repetição até completar o ciclo nesta sessão.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: state.isLoading || state.isRefreshing
                      ? null
                      : () async {
                          await ref.read(ttsServiceProvider).stop();
                          await state.randomPassage();
                          if (context.mounted) context.go('/read');
                        },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Sortear trecho da Bíblia'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _ExploreTile(
            icon: Icons.wb_sunny_outlined,
            title: 'Só Salmos',
            detail: 'Uma oração para acompanhar você',
            onTap: () async {
              await ref.read(ttsServiceProvider).stop();
              await state.randomPassage(psalmsOnly: true);
              if (context.mounted) context.go('/read');
            },
          ),
        ],
      ),
    );
  }
}

class BibleReaderScreen extends ConsumerWidget {
  const BibleReaderScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final p = state.currentPsalm;
    final matches = state.books.where((b) => b.abbrev == p?.bookAbbrev);
    final book = matches.isEmpty ? null : matches.first;
    return BibleShell(
      title: p?.reference ?? 'Sua leitura',
      subtitle: 'Leia no seu tempo',
      selected: 1,
      child: p == null
          ? const Center(child: Text('Escolha um livro para começar.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                PsalmCard(
                  psalm: p,
                  isFavorite: state.hasCurrentFavorite,
                  fontScale: state.settings.readingFontScale,
                  onFavorite: state.toggleFavorite,
                  onShare: state.shareCurrentPsalm,
                  onReadFullChapter: () async {
                    await ref.read(ttsServiceProvider).stop();
                    await state.openChapter(p.bookAbbrev, p.chapter);
                  },
                  onFontDecrease: state.decreaseReadingFont,
                  onFontIncrease: state.increaseReadingFont,
                  onListen: () => context.go('/listen'),
                ),
                const SizedBox(height: 18),
                if (book != null)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: p.chapter <= 1
                            ? null
                            : () async {
                                await ref.read(ttsServiceProvider).stop();
                                await state.openChapter(
                                  book.abbrev,
                                  p.chapter - 1,
                                );
                              },
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Anterior'),
                      ),
                      OutlinedButton.icon(
                        onPressed: p.chapter >= book.chapters.length
                            ? null
                            : () async {
                                await ref.read(ttsServiceProvider).stop();
                                await state.openChapter(
                                  book.abbrev,
                                  p.chapter + 1,
                                );
                              },
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Próximo'),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: state.isRefreshing
                      ? null
                      : () async {
                          await ref.read(ttsServiceProvider).stop();
                          await state.randomPassage(
                            psalmsOnly: p.bookAbbrev == 'sl',
                          );
                        },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Sortear outro trecho'),
                ),
              ],
            ),
    );
  }
}
