import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_footer_nav.dart';
import '../../shared/widgets/empty_state.dart';
import '../psalm/presentation/app_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: const AppFooterNav(
        current: AppFooterDestination.favorites,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _FavoritesHeader(onBack: () => context.go('/')),
              Expanded(
                child: controller.favorites.isEmpty
                    ? const EmptyState(
                        icon: Icons.favorite_border_rounded,
                        message: AppStrings.emptyFavorites,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: controller.favorites.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final psalm = controller.favorites[index];
                          return _PsalmTile(
                            title: psalm.reference,
                            subtitle: psalm.text,
                            trailing: Icons.chevron_right_rounded,
                            onTap: () {
                              controller.showPsalm(psalm);
                              context.go('/read');
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              AppStrings.favorites,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _PsalmTile extends StatelessWidget {
  const _PsalmTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Icon(trailing),
      ),
    );
  }
}
