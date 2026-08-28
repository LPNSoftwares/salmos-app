import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_footer_nav.dart';
import '../../../shared/widgets/psalm_card.dart';
import '../../tts/tts_service.dart';
import 'app_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    final psalm = controller.currentPsalm;

    return Scaffold(
      floatingActionButton: psalm == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await ref.read(ttsServiceProvider).stop();
                await ref.read(appControllerProvider).fetchNewPsalm();
              },
              icon: controller.isRefreshing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: const Text('Novo Salmo'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: psalm == null
          ? null
          : const AppFooterNav(current: AppFooterDestination.home),
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                pinned: false,
                toolbarHeight: 86,
                titleSpacing: 20,
                title: const _HomeHeader(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: controller.isLoading
                        ? const _HomeSkeleton()
                        : psalm == null
                        ? _FirstLoadError(
                            isRefreshing: controller.isRefreshing,
                            onRetry: controller.fetchNewPsalm,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (controller.message != null) ...[
                                _Notice(message: controller.message!),
                                const SizedBox(height: 10),
                              ],
                              PsalmCard(
                                psalm: psalm,
                                isFavorite: controller.hasCurrentFavorite,
                                fontScale: controller.settings.readingFontScale,
                                onFavorite: controller.toggleFavorite,
                                onShare: controller.shareCurrentPsalm,
                                onReadFullChapter: () async {
                                  await ref.read(ttsServiceProvider).stop();
                                  await controller.fetchPsalmChapter(
                                    psalm.chapter,
                                  );
                                },
                                onFontDecrease: controller.decreaseReadingFont,
                                onFontIncrease: controller.increaseReadingFont,
                                onListen: () => context.go('/listen'),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(Icons.wb_sunny_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                'Uma palavra para iluminar seu dia',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _FirstLoadError extends StatelessWidget {
  const _FirstLoadError({required this.isRefreshing, required this.onRetry});

  final bool isRefreshing;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 56,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar a API agora.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque para tentar novamente. Quando houver cache local, o app abre mesmo sem resposta da API.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: isRefreshing ? null : onRetry,
            icon: isRefreshing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(child: SizedBox(height: index == 1 ? 220 : 68)),
        ),
      ),
    );
  }
}
