import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salmododia_app/core/theme/app_theme.dart';
import 'package:salmododia_app/features/bible/bible_repository.dart';
import 'package:salmododia_app/features/bible/bible_screens.dart';
import 'package:salmododia_app/features/bible/collection_screen.dart';
import 'package:salmododia_app/features/notifications/notification_service.dart';
import 'package:salmododia_app/features/psalm/domain/psalm.dart';
import 'package:salmododia_app/features/psalm/presentation/app_controller.dart';
import 'package:salmododia_app/features/settings/app_settings.dart';
import 'package:salmododia_app/shared/services/local_storage_service.dart';

class OfflineNotifications extends NotificationService {
  @override
  Future<void> scheduleDailyPsalms({
    required AppSettings settings,
    required List<Psalm> cache,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppController controller;
  late LocalStorageService storage;
  Future<void> prepare() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.create();
    final repository = PsalmRepository();
    controller = AppController(
      repository: repository,
      storage: storage,
      notifications: OfflineNotifications(),
    );
    await controller.initialize();
  }

  for (final variant in [
    (320.0, false),
    (412.0, false),
    (800.0, false),
    (320.0, true),
    (412.0, true),
    (800.0, true),
  ]) {
    final (width, dark) = variant;
    testWidgets('offline navigation width ${width.toInt()} dark=$dark', (
      tester,
    ) async {
      await tester.runAsync(prepare);
      expect(controller.books.length, 66);
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const OfflineHomeScreen()),
          GoRoute(
            path: '/bible',
            builder: (_, _) => const BibleLibraryScreen(),
          ),
          GoRoute(
            path: '/psalms',
            builder: (_, _) => const BibleLibraryScreen(psalmsOnly: true),
          ),
          GoRoute(path: '/read', builder: (_, _) => const BibleReaderScreen()),
          GoRoute(path: '/discover', builder: (_, _) => const DiscoverScreen()),
          GoRoute(
            path: '/favorites',
            builder: (_, _) => const CollectionScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      final boundary = GlobalKey();
      if (Platform.environment['UPDATE_PREVIEWS'] == '1') {
        final font = File('C:/Windows/Fonts/segoeui.ttf');
        if (font.existsSync()) {
          await tester.runAsync(() async {
            final loader = FontLoader('Roboto')
              ..addFont(font.readAsBytes().then(ByteData.sublistView));
            await loader.load();
            final testFont = FontLoader('Ahem')
              ..addFont(font.readAsBytes().then(ByteData.sublistView));
            await testFont.load();
            final icons = File(
              'C:/src/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            );
            if (icons.existsSync()) {
              await (FontLoader('MaterialIcons')
                    ..addFont(icons.readAsBytes().then(ByteData.sublistView)))
                  .load();
            }
          });
        }
      }
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appControllerProvider.overrideWith((ref) => controller),
            localStorageProvider.overrideWithValue(storage),
          ],
          child: RepaintBoundary(
            key: boundary,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Seu momento de paz'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (Platform.environment['UPDATE_PREVIEWS'] == '1' && width == 412) {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await render.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/previews').create(recursive: true);
          await File(
            'build/previews/offline-home${dark ? '-dark' : ''}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
        });
      }
      await tester.tap(find.text('Bíblia').last);
      await tester.pumpAndSettle();
      expect(find.text('Gênesis'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'principio');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Gênesis 1:1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      router.go('/psalms');
      await tester.pumpAndSettle();
      expect(find.text('Escolha um capítulo'), findsOneWidget);
      await tester.runAsync(() => controller.openChapter('sl', 23));
      router.go('/read');
      await tester.pumpAndSettle();
      expect(find.text('Salmos 23'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.runAsync(controller.toggleFavorite);
      router.go('/favorites');
      await tester.pumpAndSettle();
      expect(find.text('Salmos 23'), findsOneWidget);
      expect(storage.getFavorites().single.bookAbbrev, 'sl');
      expect(tester.takeException(), isNull);
    });
  }
}
