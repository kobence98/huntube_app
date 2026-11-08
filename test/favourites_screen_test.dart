import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huntube_app/core/providers/files_provider.dart';
import 'package:huntube_app/core/providers/isar_provider.dart';
import 'package:huntube_app/domain/models/cache/cached_like.dart';
import 'package:huntube_app/domain/models/file_data.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/presentation/features/favourites/favourites_screen.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:huntube_app/presentation/widgets/progress_bar.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final eventChannels = <MethodChannel>[];

  setUp(() {
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
          final arguments = call.arguments as Map;
          final channel = MethodChannel(
            'xyz.luan/audioplayers/events/${arguments['playerId']}',
          );
          eventChannels.add(channel);
          messenger.setMockMethodCallHandler(channel, (_) async => null);
        }
        return null;
      },
    );
  });

  tearDown(() {
    for (final channel in eventChannels) {
      messenger.setMockMethodCallHandler(channel, null);
    }
    eventChannels.clear();
    for (final name in [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
  });

  FileData sound(int id, String title) =>
      FileData(id: id, title: title, assetName: 'sound_$id');

  Future<void> openFavourites(
    WidgetTester tester,
    List<PartFiles> parts,
    Stream<List<CachedLike>> likes,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readFilesProvider.overrideWith((ref) async => parts),
          cachedLikesProvider.overrideWith((ref) => likes),
        ],
        child: MaterialApp(theme: appTheme, home: const FavouritesScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> closeFavourites(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('shows only liked sounds under their collection and episode', (
    tester,
  ) async {
    final parts = [
      PartFiles(
        id: 0,
        title: 'Kedvelt rész',
        files: [sound(0, 'Kedvenc hang'), sound(1, 'Nem kedvelt hang')],
      ),
      PartFiles(id: 1, title: 'Üres rész', files: [sound(2, 'Másik hang')]),
      PartFiles(
        id: 2,
        title: 'Karib rész',
        collection: PartCollection.karib,
        files: [sound(3, 'Karib hang')],
      ),
    ];
    await openFavourites(
      tester,
      parts,
      Stream.value(const [CachedLike(id: 0), CachedLike(id: 999)]),
    );
    expect(find.text('Kedvencek'), findsOneWidget);
    expect(find.text('Herri'), findsOneWidget);
    expect(find.text('Kedvelt rész'), findsOneWidget);
    expect(find.text('Kedvenc hang'), findsOneWidget);
    for (final hidden in [
      'Nem kedvelt hang',
      'Másik hang',
      'Üres rész',
      'Karib',
      'Karib rész',
    ]) {
      expect(find.text(hidden), findsNothing);
    }
    expect(find.byType(ProgressBar), findsOneWidget);
    expect(
      tester.widget<ProgressBar>(find.byType(ProgressBar)).key,
      const ValueKey(0),
    );
    expect(tester.takeException(), isNull);
    await closeFavourites(tester);
  });

  testWidgets(
    'removing final likes removes sections and shows empty guidance',
    (tester) async {
      final likes = StreamController<List<CachedLike>>();
      addTearDown(likes.close);
      likes.add(const [CachedLike(id: 0), CachedLike(id: 1)]);
      await openFavourites(tester, [
        PartFiles(id: 0, title: 'Herri rész', files: [sound(0, 'Herri hang')]),
        PartFiles(
          id: 1,
          title: 'Karib rész',
          collection: PartCollection.karib,
          files: [sound(1, 'Karib hang')],
        ),
      ], likes.stream);
      expect(find.text('Herri hang'), findsOneWidget);
      expect(find.text('Karib hang'), findsOneWidget);
      likes.add(const [CachedLike(id: 1)]);
      await tester.pumpAndSettle();
      expect(find.text('Herri'), findsNothing);
      expect(find.text('Herri rész'), findsNothing);
      expect(find.text('Herri hang'), findsNothing);
      expect(find.text('Karib hang'), findsOneWidget);
      likes.add(const [CachedLike(id: 999)]);
      await tester.pumpAndSettle();
      expect(find.text('Karib'), findsNothing);
      expect(find.text('Karib rész'), findsNothing);
      expect(find.byType(ProgressBar), findsNothing);
      expect(find.text('Még nincs kedvenced'), findsOneWidget);
      expect(
        find.text('Húzz jobbra egy hangot, és itt is megtalálod.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(tester.takeException(), isNull);
      await closeFavourites(tester);
    },
  );

  testWidgets(
    'mixed collections share one lazy scroll view in collection order',
    (tester) async {
      final herriSounds = List.generate(
        30,
        (index) => sound(index, 'Herri hang $index'),
      );
      final parts = [
        PartFiles(
          id: 2,
          title: 'Karib rész',
          collection: PartCollection.karib,
          files: [sound(90, 'Karib utolsó hang')],
        ),
        PartFiles(
          id: 1,
          title: 'Gyűrű rész',
          collection: PartCollection.gyuru,
          files: [sound(80, 'Gyűrű hang')],
        ),
        PartFiles(id: 0, title: 'Herri rész', files: herriSounds),
      ];
      await openFavourites(
        tester,
        parts,
        Stream.value([
          for (final file in [
            ...herriSounds,
            sound(80, 'Gyűrű hang'),
            sound(90, 'Karib utolsó hang'),
          ])
            CachedLike(id: file.id),
        ]),
      );
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      expect(
        tester
            .widgetList<H2Text>(find.byType(H2Text))
            .map((widget) => widget.text),
        ['Herri'],
      );
      expect(find.byKey(const ValueKey(29)), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Gyűrű'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();
      expect(find.text('Gyűrű').hitTestable(), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Gyűrű')).dy,
        lessThan(tester.getTopLeft(find.text('Karib')).dy),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey(90)),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();
      expect(find.text('Karib utolsó hang').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await closeFavourites(tester);
    },
  );
}
