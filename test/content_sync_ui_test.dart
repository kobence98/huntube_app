import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huntube_app/core/providers/content_sync_provider.dart';
import 'package:huntube_app/core/providers/files_provider.dart';
import 'package:huntube_app/core/providers/isar_provider.dart';
import 'package:huntube_app/core/router/the_just_matthew_router.dart';
import 'package:huntube_app/core/router/the_just_matthew_router.gr.dart';
import 'package:huntube_app/domain/models/cache/cached_like.dart';
import 'package:huntube_app/domain/models/file_data.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/presentation/features/favourites/favourites_screen.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:huntube_app/presentation/widgets/progress_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const newCollection = PartCollection('remote_parody', 'Új főmappa');
  const emptyCollection = PartCollection('empty_main', 'Üres főmappa');
  const remoteSound = FileData(
    id: 1000000,
    title: 'Letöltött hang',
    assetName: 'remote_1000000',
    localPath: '/offline/audio/1000000.mp3',
  );
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(name),
        (_) async => null,
      );
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        calls.add(call);
        final arguments = call.arguments as Map?;
        final id = arguments?['playerId'];
        if (call.method == 'create') {
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null,
          );
        }
        if (call.method == 'setSourceUrl') {
          await messenger.handlePlatformMessage(
            'xyz.luan/audioplayers/events/$id',
            const StandardMethodCodec().encodeSuccessEnvelope({
              'event': 'audio.onPrepared',
              'value': true,
            }),
            (_) {},
          );
        }
        return null;
      },
    );
  });

  testWidgets(
    'declared empty main folder is visible and opens without a network request',
    (tester) async {
      final router = TheJustMatthewRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readFilesProvider.overrideWith((ref) async => <PartFiles>[]),
            downloadedCollectionsProvider.overrideWith(
              (ref) async => [emptyCollection],
            ),
          ],
          child: MaterialApp.router(
            theme: appTheme,
            routerConfig: router.config(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Üres főmappa'));
      await tester.tap(find.text('Üres főmappa'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(router.current.name, CollectionPartsRoute.name);
      expect(find.text('Ebben a mappában még nincs rész.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('new main folder opens its empty subfolder offline', (
    tester,
  ) async {
    const part = PartFiles(
      id: 1000000,
      title: 'Új üres almappa',
      collection: newCollection,
      files: [],
    );
    final router = TheJustMatthewRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readFilesProvider.overrideWith((ref) async => [part]),
          downloadedCollectionsProvider.overrideWith(
            (ref) async => [newCollection],
          ),
          cachedLikesProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp.router(
          theme: appTheme,
          routerConfig: router.config(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Új főmappa'));
    await tester.tap(find.text('Új főmappa'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Új üres almappa'), findsOneWidget);
    await tester.tap(find.text('Új üres almappa'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(router.current.name, OnePartListRoute.name);
    expect(find.text('Új üres almappa'), findsOneWidget);
    expect(find.byType(ProgressBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'downloaded audio is played from its local file rather than a bundled asset or URL',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cachedLikesProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: appTheme,
            home: const Scaffold(
              body: ProgressBar(
                fileData: remoteSound,
                easterEggActivated: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Letöltött hang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      final sources = calls
          .where((call) => call.method == 'setSourceUrl')
          .toList();
      expect(sources, isNotEmpty);
      for (final source in sources) {
        expect((source.arguments as Map)['url'], '/offline/audio/1000000.mp3');
        expect((source.arguments as Map)['isLocal'], isTrue);
      }
      expect(calls.any((call) => call.method == 'resume'), isTrue);
      expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'remote favorites remain grouped under their dynamically declared main folder',
    (tester) async {
      const part = PartFiles(
        id: 1000000,
        title: 'Új rész',
        collection: newCollection,
        files: [remoteSound],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readFilesProvider.overrideWith((ref) async => [part]),
            cachedLikesProvider.overrideWith(
              (ref) => Stream.value([const CachedLike(id: 1000000)]),
            ),
          ],
          child: MaterialApp(theme: appTheme, home: const FavouritesScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Új főmappa'), findsOneWidget);
      expect(find.text('Új rész'), findsOneWidget);
      expect(find.text('Letöltött hang'), findsOneWidget);
      expect(find.byKey(const ValueKey('liked-badge-1000000')), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed refresh reports offline availability and keeps bundled folders usable',
    (tester) async {
      final router = TheJustMatthewRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readFilesProvider.overrideWith((ref) async => <PartFiles>[]),
            downloadedCollectionsProvider.overrideWith(
              (ref) async => <PartCollection>[],
            ),
            contentStoreProvider.overrideWith(
              (ref) async => throw const SocketException('Offline'),
            ),
          ],
          child: MaterialApp.router(
            theme: appTheme,
            routerConfig: router.config(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Új hangok keresése'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frissítés'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('A meglévő hangok offline is elérhetők.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Bezárás'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Herri'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(router.current.name, CollectionPartsRoute.name);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('open folders and subfolders refresh when the catalog changes', (
    tester,
  ) async {
    const firstPart = PartFiles(
      id: 1000000,
      title: 'Régi résznév',
      collection: newCollection,
      files: [],
    );
    const renamedPart = PartFiles(
      id: 1000000,
      title: 'Új résznév',
      collection: newCollection,
      files: [],
    );
    const latestPart = PartFiles(
      id: 1000000,
      title: 'Legfrissebb résznév',
      collection: newCollection,
      files: [],
    );
    final liveCatalog = StateProvider<List<PartFiles>>((ref) => [firstPart]);
    final router = TheJustMatthewRouter();
    addTearDown(router.dispose);
    final container = ProviderContainer(
      overrides: [
        readFilesProvider.overrideWith((ref) async => ref.watch(liveCatalog)),
        downloadedCollectionsProvider.overrideWith(
          (ref) async => [newCollection],
        ),
        cachedLikesProvider.overrideWith((ref) => Stream.value([])),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: appTheme,
          routerConfig: router.config(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Új főmappa'));
    await tester.tap(find.text('Új főmappa'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Régi résznév'), findsOneWidget);
    container.read(liveCatalog.notifier).state = [renamedPart];
    await tester.pumpAndSettle();
    expect(find.text('Régi résznév'), findsNothing);
    expect(find.text('Új résznév'), findsOneWidget);
    await tester.tap(find.text('Új résznév'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(router.current.name, OnePartListRoute.name);
    container.read(liveCatalog.notifier).state = [latestPart];
    await tester.pumpAndSettle();
    expect(find.text('Legfrissebb résznév'), findsOneWidget);
    expect(find.text('Új résznév'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
