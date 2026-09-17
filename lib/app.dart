import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/bible/collection_screen.dart';
import 'features/psalm/presentation/app_controller.dart';
import 'features/bible/bible_screens.dart';
import 'features/settings/settings_screen.dart';
import 'features/tts/presentation/listen_psalm_screen.dart';

class SalmoDoDiaApp extends ConsumerStatefulWidget {
  const SalmoDoDiaApp({super.key});

  @override
  ConsumerState<SalmoDoDiaApp> createState() => _SalmoDoDiaAppState();
}

class _SalmoDoDiaAppState extends ConsumerState<SalmoDoDiaApp> {
  late final GoRouter _router;
  StreamSubscription<String>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const OfflineHomeScreen(),
          routes: [
            GoRoute(
              path: 'bible',
              builder: (context, state) => const BibleLibraryScreen(),
            ),
            GoRoute(
              path: 'psalms',
              builder: (context, state) =>
                  const BibleLibraryScreen(psalmsOnly: true),
            ),
            GoRoute(
              path: 'discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
            GoRoute(
              path: 'read',
              builder: (context, state) => const BibleReaderScreen(),
            ),
            GoRoute(
              path: 'favorites',
              builder: (context, state) => const CollectionScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) =>
                  const CollectionScreen(history: true),
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

    Future.microtask(() async {
      if (!mounted) return;
      final controller = ref.read(appControllerProvider);
      _notificationSubscription = controller.notificationPayloads.listen((_) {
        if (mounted) {
          _router.go('/read');
        }
      });
      await controller.initialize();
      if (mounted && controller.openedFromNotification) _router.go('/read');
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _router.dispose();
    super.dispose();
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
