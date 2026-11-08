import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huntube_app/core/providers/isar_provider.dart';
import 'package:huntube_app/domain/models/cache/cached_like.dart';
import 'package:huntube_app/domain/models/file_data.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:huntube_app/presentation/widgets/progress_bar.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';
import 'package:isar/isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final packageConfigFile = File('.dart_tool/package_config.json').absolute;
    final config =
        jsonDecode(await packageConfigFile.readAsString())
            as Map<String, dynamic>;
    final packages = (config['packages'] as List).cast<Map<String, dynamic>>();
    final native = packages.singleWhere(
      (package) => package['name'] == 'isar_flutter_libs',
    );
    final root = packageConfigFile.uri.resolve(native['rootUri'] as String);
    final library = Platform.isMacOS
        ? 'macos/libisar.dylib'
        : Platform.isWindows
        ? 'windows/isar.dll'
        : 'linux/libisar.so';
    await Isar.initializeIsarCore(
      libraries: {
        Abi.current(): Directory.fromUri(
          root,
        ).uri.resolve(library).toFilePath(),
      },
    );
  });

  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global/events'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        if (call.method == 'create') {
          final id = (call.arguments as Map)['playerId'];
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null,
          );
        }
        return null;
      },
    );
  });

  Future<StreamController<List<CachedLike>>> pumpTile(
    WidgetTester tester, {
    bool initiallyLiked = false,
    bool reduceMotion = false,
    double textScale = 1,
    String title = 'Több gőzt!',
  }) async {
    final likes = StreamController<List<CachedLike>>.broadcast(sync: true);
    addTearDown(likes.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cachedLikesProvider.overrideWith((ref) => likes.stream)],
        child: MaterialApp(
          theme: appTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reduceMotion,
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 320,
                child: ProgressBar(
                  fileData: FileData(
                    id: 148,
                    title: title,
                    assetName: 'karib_vader_tobb_gozt',
                  ),
                  easterEggActivated: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    likes.add(initiallyLiked ? [const CachedLike(id: 148)] : []);
    await tester.pumpAndSettle();
    return likes;
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets(
    'already-liked sound opens with a heart badge and no like burst',
    (tester) async {
      await pumpTile(tester, initiallyLiked: true);
      expect(find.byKey(const ValueKey('liked-badge-148')), findsOneWidget);
      expect(find.byKey(const ValueKey('like-burst-148')), findsNothing);
      final paint = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((widget) => widget.painter is HeartPatternPainter);
      expect(paint, hasLength(1));
      await unmount(tester);
    },
  );

  testWidgets(
    'new favourite has one finite heart animation and stable swipe state',
    (tester) async {
      final likes = await pumpTile(tester);
      final swipe = tester.element(find.byType(Dismissible));
      likes.add([const CachedLike(id: 148)]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.byKey(const ValueKey('like-burst-148')), findsOneWidget);
      expect(find.byKey(const ValueKey('liked-badge-148')), findsOneWidget);
      expect(
        identical(tester.element(find.byType(Dismissible)), swipe),
        isTrue,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('like-burst-148')), findsNothing);
      likes.add([const CachedLike(id: 148)]);
      await tester.pump();
      expect(find.byKey(const ValueKey('like-burst-148')), findsNothing);
      await unmount(tester);
    },
  );

  testWidgets('reduced motion keeps the favourite feedback static', (
    tester,
  ) async {
    final likes = await pumpTile(tester, reduceMotion: true);
    likes.add([const CachedLike(id: 148)]);
    await tester.pump();
    expect(find.byKey(const ValueKey('liked-badge-148')), findsOneWidget);
    expect(find.byKey(const ValueKey('like-burst-148')), findsNothing);
    await tester.pumpAndSettle();
    await unmount(tester);
  });

  testWidgets(
    'long labels grow and stay centered inside padding at large text scale',
    (tester) async {
      const title =
          'Egy különösen hosszú régi hangcím amely több sorban is teljesen olvasható marad';
      await pumpTile(tester, title: title, initiallyLiked: true, textScale: 2);
      final surface = tester.getRect(
        find.byKey(const ValueKey('sound-surface-148')),
      );
      final label = tester.getRect(find.text(title));
      expect(surface.height, greaterThan(64));
      expect(label.left - surface.left, greaterThanOrEqualTo(40));
      expect(surface.right - label.right, greaterThanOrEqualTo(40));
      expect(label.top - surface.top, greaterThanOrEqualTo(8));
      expect(surface.bottom - label.bottom, greaterThanOrEqualTo(8));
      expect(
        tester.widget<H3Text>(find.byType(H3Text)).textAlign,
        TextAlign.center,
      );
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'swipe actions await real local favourite writes in both directions',
    (tester) async {
      final directory = await tester.runAsync(
        () => Directory.systemTemp.createTemp('herri-tile-'),
      );
      final isar = await tester.runAsync(
        () => Isar.open(
          [CachedLikeSchema],
          directory: directory!.path,
          inspector: false,
        ),
      );
      final likes = StreamController<List<CachedLike>>.broadcast(sync: true);
      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) async => isar!),
          cachedLikesProvider.overrideWith((ref) => likes.stream),
        ],
      );
      await tester.runAsync(() => container.read(isarProvider.future));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: appTheme,
            home: Scaffold(
              body: ProgressBar(
                fileData: FileData(
                  id: 148,
                  title: 'Több gőzt!',
                  assetName: 'karib_vader_tobb_gozt',
                ),
                easterEggActivated: false,
              ),
            ),
          ),
        ),
      );
      likes.add([]);
      await tester.pumpAndSettle();
      final add = tester
          .widget<Dismissible>(find.byType(Dismissible))
          .confirmDismiss!;
      expect(
        await tester.runAsync(() => add(DismissDirection.startToEnd)),
        isFalse,
      );
      expect(
        await tester.runAsync(() => isar!.cachedLikes.get(148)),
        isNotNull,
      );
      likes.add([const CachedLike(id: 148)]);
      await tester.pumpAndSettle();
      final remove = tester
          .widget<Dismissible>(find.byType(Dismissible))
          .confirmDismiss!;
      expect(
        await tester.runAsync(() => remove(DismissDirection.endToStart)),
        isFalse,
      );
      expect(await tester.runAsync(() => isar!.cachedLikes.get(148)), isNull);
      await unmount(tester);
      container.dispose();
      await likes.close();
      await tester.runAsync(() => isar!.close());
      await tester.runAsync(() => directory!.delete(recursive: true));
    },
  );
}
