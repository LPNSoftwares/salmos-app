import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_footer_nav.dart';
import '../../shared/widgets/empty_state.dart';
import '../psalm/presentation/app_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appControllerProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: const AppFooterNav(
        current: AppFooterDestination.history,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _HistoryHeader(
                canClear: controller.history.isNotEmpty,
                onBack: () => context.go('/'),
                onClear: controller.clearHistory,
              ),
              Expanded(
                child: controller.history.isEmpty
                    ? const EmptyState(
                        icon: Icons.history_rounded,
                        message: AppStrings.emptyHistory,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: controller.history.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final psalm = controller.history[index];
                          return GlassCard(
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              onTap: () {
                                controller.showPsalm(psalm);
                                context.go('/');
                              },
                              leading: const Icon(Icons.auto_stories_rounded),
                              title: Text(
                                psalm.reference,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                psalm.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(psalm.version.toUpperCase()),
                            ),
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

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.canClear,
    required this.onBack,
    required this.onClear,
  });

  final bool canClear;
  final VoidCallback onBack;
  final Future<void> Function() onClear;

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
              AppStrings.history,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          TextButton(
            onPressed: canClear ? onClear : null,
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}
