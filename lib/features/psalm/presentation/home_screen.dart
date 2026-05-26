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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref.read(ttsServiceProvider).stop();
          await ref.read(appControllerProvider).fetchNewPsalm();
        },
        backgroundColor: const Color(0xFF0B1830).withValues(alpha: 0.98),
        child: Icon(Icons.refresh_outlined, color: Colors.white, size: 42),
      ),
      backgroundColor: Theme.of(context).iconTheme.color,
      bottomNavigationBar: psalm == null
          ? null
          : const AppFooterNav(current: AppFooterDestination.home),
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                title: const Text(AppStrings.appName),
                floating: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
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
