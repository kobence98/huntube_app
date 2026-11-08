import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huntube_app/core/providers/files_provider.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:huntube_app/generated/assets.gen.dart';
import 'package:huntube_app/presentation/features/home/home_screen.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every listed sound resolves to a bundled MP3 with a stable unique ID',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final parts = await container.read(readFilesProvider.future);
      expect(parts, isNotEmpty);
      final sounds = parts.expand((part) => part.files).toList();
      expect(sounds.length, 249);
      final pom = parts.singleWhere(
        (part) => part.collection == PartCollection.pom,
      );
      expect(pom.title, 'Torzonborz faszverő');
      expect(pom.files.length, 36);
      expect(pom.files.first.id, 213);
      final legacyAssets = File(
        'test/fixtures/legacy_sound_assets.txt',
      ).readAsLinesSync();
      expect(sounds.take(213).map((sound) => sound.assetName), legacyAssets);
      expect(
        sounds.take(213).map((sound) => sound.id),
        List.generate(213, (i) => i),
      );
      final gyuru = parts.singleWhere(
        (part) => part.collection == PartCollection.gyuru,
      );
      expect(gyuru.title, 'A Gyűrű Szövetsége part 1');
      expect(gyuru.files.length, 36);
      expect(gyuru.files.first.id, 177);
      expect(
        gyuru.files.map((sound) => sound.assetName),
        contains('gyuru_szovetseg_1_gandalf_bilbo_ajtos_beszelgetes'),
      );
      expect(
        parts.where((part) => part.collection == PartCollection.srekk),
        isEmpty,
      );
      final karibVader = parts.singleWhere(
        (part) => part.collection == PartCollection.karib,
      );
      expect(karibVader.title, 'A csillag végén');
      expect(karibVader.collection, PartCollection.karib);
      expect(
        parts.take(4).every((part) => part.collection == PartCollection.herri),
        isTrue,
      );
      expect(karibVader.files.length, 29);
      expect(karibVader.files.first.id, 148);
      expect(
        karibVader.files.map((sound) => sound.title),
        containsAll(['Emberhajók', 'Több gőzt!']),
      );
      expect(sounds.map((sound) => sound.id).toSet().length, sounds.length);
      for (final sound in sounds) {
        expect(sound.title, isNotEmpty);
        expect(
          File('assets/audios/${sound.assetName}.mp3').existsSync(),
          isTrue,
          reason: 'Missing audio for ${sound.title}',
        );
        expect(
          Assets.audios.values,
          contains('assets/audios/${sound.assetName}.mp3'),
          reason: 'Missing playback registry entry for ${sound.title}',
        );
      }
    },
  );

  testWidgets('home displays the bundled parody collections', (tester) async {
    final parts = [
      const PartFiles(id: 0, title: 'Senki nem szereti Harryt', files: []),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [readFilesProvider.overrideWith((ref) async => parts)],
        child: MaterialApp(theme: appTheme, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('R.I.P TheJustMatthew'), findsOneWidget);
    for (final collection in PartCollection.values) {
      expect(find.text(collection.title), findsOneWidget);
    }
    expect(find.text(parts.first.title), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
