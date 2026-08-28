import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/history/history_screen.dart';
import 'features/psalm/presentation/app_controller.dart';
import 'features/psalm/presentation/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/tts/presentation/listen_psalm_screen.dart';

class SalmoDoDiaApp extends ConsumerStatefulWidget {
  const SalmoDoDiaApp({super.key});

  @override
  ConsumerState<SalmoDoDiaApp> createState() => _SalmoDoDiaAppState();
}

class _SalmoDoDiaAppState extends ConsumerState<SalmoDoDiaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => const HistoryScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: 'listen',
              builder: (context, state) => const ListenPsalmScreen(),
            ),
          ],
        ),
      ],
    );

    Future.microtask(() {
      ref.read(appControllerProvider).initialize();
      ref.read(appControllerProvider).notificationPayloads.listen((_) {
        if (mounted) {
          _router.go('/');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: state.settings.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.systemOverlayStyle(Theme.of(context).brightness),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
