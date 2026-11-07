import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huntube_app/core/providers/files_provider.dart';
import 'package:huntube_app/core/providers/isar_provider.dart';
import 'package:huntube_app/core/router/the_just_matthew_router.dart';
import 'package:huntube_app/core/router/the_just_matthew_router.gr.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/presentation/features/one_part_list/one_part_list_screen.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

void main() {
  testWidgets('collections separate episodes and support round-trip navigation', (
    tester,
  ) async {
    const herriEpisodes = [
      PartFiles(id: 0, title: 'Herri első rész', files: []),
      PartFiles(id: 1, title: 'Herri második rész', files: []),
      PartFiles(id: 2, title: 'Herri harmadik rész', files: []),
      PartFiles(id: 3, title: 'Herri negyedik rész', files: []),
    ];
    const karibEpisode = PartFiles(
      id: 4,
      title: 'A csillag végén',
      files: [],
      collection: PartCollection.karib,
    );
    const gyuruEpisode = PartFiles(
      id: 5,
      title: 'A Gyűrű Szövetsége part 1',
      files: [],
      collection: PartCollection.gyuru,
    );
    const allEpisodes = [...herriEpisodes, karibEpisode, gyuruEpisode];
    final router = TheJustMatthewRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readFilesProvider.overrideWith((ref) async => allEpisodes),
          cachedLikesProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp.router(
          routerConfig: router.config(),
          theme: appTheme,
        ),
      ),
    );
    await tester.pumpAndSettle();

    void expectRoot() {
      expect(router.current.name, HomeRoute.name);
      expect(
        tester
            .widgetList<H3AutosizeText>(find.byType(H3AutosizeText))
            .map((widget) => widget.text),
        ['Herri', 'Gyűrű', 'Srekk', 'Karib'],
      );
      for (final episode in allEpisodes) {
        expect(find.text(episode.title), findsNothing);
      }
    }

    Future<void> tapAndNavigate(Finder target) async {
      await tester.tap(target);
      // The existing buttons schedule navigation and release their pressed state.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
    }

    expectRoot();
    await tapAndNavigate(find.text('Herri'));
    expect(router.current.name, CollectionPartsRoute.name);
    for (final episode in herriEpisodes) {
      expect(find.text(episode.title), findsOneWidget);
    }
    expect(find.text(karibEpisode.title), findsNothing);

    await tapAndNavigate(find.text(herriEpisodes.first.title));
    expect(router.current.name, OnePartListRoute.name);
    final episodeScreen = tester.widget<OnePartListScreen>(
      find.byType(OnePartListScreen),
    );
    expect(identical(episodeScreen.partFiles, herriEpisodes.first), isTrue);
    expect(episodeScreen.easterEggActivated, isFalse);
    expect(find.text(herriEpisodes.first.title), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tapAndNavigate(find.byIcon(Icons.arrow_back));
    expect(router.current.name, CollectionPartsRoute.name);
    await tapAndNavigate(find.byIcon(Icons.arrow_back));
    expectRoot();

    await tapAndNavigate(find.text('Karib'));
    expect(router.current.name, CollectionPartsRoute.name);
    expect(find.text(karibEpisode.title), findsOneWidget);
    for (final episode in herriEpisodes) {
      expect(find.text(episode.title), findsNothing);
    }
    await tapAndNavigate(find.byIcon(Icons.arrow_back));
    expectRoot();

    await tapAndNavigate(find.text('Gyűrű'));
    expect(find.text(gyuruEpisode.title), findsOneWidget);
    expect(find.text(karibEpisode.title), findsNothing);
    for (final episode in herriEpisodes) {
      expect(find.text(episode.title), findsNothing);
    }
    await tapAndNavigate(find.text(gyuruEpisode.title));
    expect(router.current.name, OnePartListRoute.name);
    expect(
      identical(
        tester
            .widget<OnePartListScreen>(find.byType(OnePartListScreen))
            .partFiles,
        gyuruEpisode,
      ),
      isTrue,
    );
    await tapAndNavigate(find.byIcon(Icons.arrow_back));
    await tapAndNavigate(find.byIcon(Icons.arrow_back));
    expectRoot();

    await tapAndNavigate(find.text('Srekk'));
    expect(router.current.name, CollectionPartsRoute.name);
    expect(find.text('Srekk'), findsOneWidget);
    expect(find.text('Ebben a mappában még nincs rész.'), findsOneWidget);
    for (final episode in allEpisodes) {
      expect(find.text(episode.title), findsNothing);
    }
    expect(tester.takeException(), isNull);

    await tapAndNavigate(find.byIcon(Icons.arrow_back));
    expectRoot();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
