import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huntube_app/data/content/content_store.dart';

void main() {
  late Directory directory;
  final manifestUri = Uri.parse(
    'https://drive.google.com/uc?export=download&id=manifest123',
  );
  final first = utf8.encode('first test audio');
  final second = utf8.encode('second test audio');

  Map<String, Object> sound(int id, List<int> bytes) => {
    'id': id,
    'title': 'Sound $id',
    'driveFileId': 'drive_file_$id',
    'sha256': sha256.convert(bytes).toString(),
    'bytes': bytes.length,
  };
  Map<String, Object> catalog(List<Map<String, Object>> sounds) => {
    'schemaVersion': 1,
    'parts': [
      {
        'id': 1000000,
        'title': 'New episode',
        'collection': 'herri',
        'sounds': sounds,
      },
    ],
  };
  late Map<String, Object> remote;
  late List<String> requests;
  var offline = false;
  Future<List<int>> fetch(Uri uri, int maxBytes) async {
    requests.add(uri.toString());
    if (offline) throw const SocketException('Offline');
    if (uri == manifestUri) return utf8.encode(jsonEncode(remote));
    return uri.queryParameters['id'] == 'drive_file_1000000' ? first : second;
  }

  ContentStore store() => ContentStore(
    directory: directory,
    manifestUri: manifestUri,
    fetcher: fetch,
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('content-store-test-');
    remote = catalog([sound(1000000, first)]);
    requests = [];
    offline = false;
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'downloads and persists new audio for a subsequent offline launch',
    () async {
      final progress = <(int, int)>[];
      final result = await store().sync(
        onProgress: (done, total) => progress.add((done, total)),
      );
      expect(result.single.files.single.id, 1000000);
      expect(
        await File(result.single.files.single.localPath!).readAsBytes(),
        first,
      );
      expect(progress, [(0, 1), (1, 1)]);
      requests.clear();
      offline = true;
      final cached = await store().loadCached();
      expect(cached.single.files.single.title, 'Sound 1000000');
      expect(requests, isEmpty);
    },
  );

  test('reuses verified files and downloads only additions', () async {
    await store().sync();
    requests.clear();
    remote = catalog([sound(1000000, first), sound(1000001, second)]);
    final result = await store().sync();
    expect(result.single.files, hasLength(2));
    expect(requests, hasLength(2));
    expect(requests.last, contains('drive_file_1000001'));
    requests.clear();
    await store().sync();
    expect(requests, [manifestUri.toString()]);
  });

  test('failed new download preserves previous published catalog', () async {
    await store().sync();
    remote = catalog([
      sound(1000000, first),
      {...sound(1000001, second), 'sha256': '0' * 64},
    ]);
    await expectLater(store().sync(), throwsFormatException);
    expect((await store().loadCached()).single.files, hasLength(1));
    expect(
      directory.listSync().where((f) => f.path.endsWith('.part')),
      isEmpty,
    );
  });

  test('same-size corruption is hidden offline and repaired by sync', () async {
    final result = await store().sync();
    final file = File(result.single.files.single.localPath!);
    await file.writeAsBytes(List.filled(first.length, 0));
    expect(await store().loadCached(), isEmpty);
    requests.clear();
    await store().sync();
    expect(requests, hasLength(2));
    expect(await file.readAsBytes(), first);
  });

  test(
    'changed content keeps stable ID and old file until new version verifies',
    () async {
      final original = await store().sync();
      final oldPath = original.single.files.single.localPath!;
      remote = catalog([sound(1000000, second)]);
      // The fake returns the original bytes, so the update must fail validation.
      await expectLater(store().sync(), throwsFormatException);
      expect(
        (await store().loadCached()).single.files.single.localPath,
        oldPath,
      );
      final updated = await ContentStore(
        directory: directory,
        manifestUri: manifestUri,
        fetcher: (uri, limit) async =>
            uri == manifestUri ? utf8.encode(jsonEncode(remote)) : second,
      ).sync();
      expect(updated.single.files.single.id, 1000000);
      expect(updated.single.files.single.localPath, isNot(oldPath));
      expect(await File(oldPath).exists(), isTrue);
    },
  );

  test(
    'missing or corrupt local catalog falls back to bundled-only content',
    () async {
      expect(await store().loadCached(), isEmpty);
      await File('${directory.path}/catalog.json').writeAsString('{broken');
      expect(await store().loadCached(), isEmpty);
    },
  );

  test('concurrent sync calls share one download and catalog write', () async {
    final gate = Completer<void>();
    var downloads = 0;
    final service = ContentStore(
      directory: directory,
      manifestUri: manifestUri,
      fetcher: (uri, limit) async {
        downloads++;
        await gate.future;
        return fetch(uri, limit);
      },
    );
    final a = service.sync();
    final b = service.sync();
    gate.complete();
    await Future.wait([a, b]);
    expect(downloads, 2);
  });

  test('rejects IDs that collide with bundled favorites and duplicate IDs', () {
    remote = catalog([sound(0, first)]);
    expect(() => parseRemoteCatalog(jsonEncode(remote)), throwsFormatException);
    remote = catalog([sound(1000000, first), sound(1000000, second)]);
    expect(() => parseRemoteCatalog(jsonEncode(remote)), throwsFormatException);
    final part = (remote['parts'] as List).first;
    remote['parts'] = [part, part];
    expect(() => parseRemoteCatalog(jsonEncode(remote)), throwsFormatException);
  });

  test(
    'rejects unsafe filenames, unknown collections, invalid sizes and hashes',
    () {
      for (final bad in [
        {...sound(1000000, first), 'driveFileId': '../../escape'},
        {...sound(1000000, first), 'sha256': '../escape'},
        {...sound(1000000, first), 'bytes': maxSoundBytes + 1},
        {...sound(1000000, first), 'bytes': 0},
      ]) {
        expect(
          () => parseRemoteCatalog(jsonEncode(catalog([bad]))),
          throwsFormatException,
        );
      }
      final value = catalog([sound(1000000, first)]);
      ((value['parts'] as List).first as Map)['collection'] = 'unknown';
      expect(
        () => parseRemoteCatalog(jsonEncode(value)),
        throwsFormatException,
      );
    },
  );

  test('accepts only HTTPS Google hosts, including redirect destinations', () {
    for (final uri in [
      'http://drive.google.com/file',
      'https://drive.google.com.evil.com/file',
      'https://user@drive.google.com/file',
      'https://drive.google.com:8443/file',
      'https://example.com/audio.mp3',
    ]) {
      expect(isAllowedContentUri(Uri.parse(uri)), isFalse);
    }
    for (final uri in [
      'https://drive.google.com/file',
      'https://drive.usercontent.google.com/download',
      'https://doc-00.googleusercontent.com/file',
      'https://docs.google.com/document',
    ]) {
      expect(isAllowedContentUri(Uri.parse(uri)), isTrue);
    }
  });

  test(
    'new main folders and empty subfolders survive offline restart',
    () async {
      remote = {
        'schemaVersion': 1,
        'collections': [
          {'id': 'new_parody', 'title': 'Új paródia'},
          {'id': 'empty_folder', 'title': 'Hamarosan'},
        ],
        'parts': [
          {
            'id': 1000000,
            'title': 'Első rész',
            'collection': 'new_parody',
            'sounds': [sound(1000000, first)],
          },
          {
            'id': 1000001,
            'title': 'Készülő rész',
            'collection': 'new_parody',
            'sounds': <Object>[],
          },
        ],
      };
      final loaded = await store().sync();
      expect(loaded, hasLength(2));
      expect(loaded.first.collection.name, 'new_parody');
      expect(loaded.first.collection.title, 'Új paródia');
      expect(loaded.last.files, isEmpty);
      offline = true;
      final restored = await store().loadCached();
      expect(restored.last.title, 'Készülő rész');
      final collections = await store().loadCachedCollections();
      expect(collections.map((c) => c.name), ['new_parody', 'empty_folder']);
      expect(collections.last.title, 'Hamarosan');
    },
  );

  test('rejects duplicate, unsafe and overriding main folder IDs', () {
    for (final declarations in [
      [
        {'id': 'herri', 'title': 'Override'},
      ],
      [
        {'id': '../escape', 'title': 'Unsafe'},
      ],
      [
        {'id': 'valid', 'title': 'One'},
        {'id': 'valid', 'title': 'Two'},
      ],
    ]) {
      final value = catalog([])..['collections'] = declarations;
      expect(
        () => parseRemoteCatalog(jsonEncode(value)),
        throwsFormatException,
      );
    }
  });

  test('accepts Google Docs text exports with a UTF-8 BOM', () {
    final parsed = parseRemoteCatalog('\uFEFF${jsonEncode(catalog([]))}');
    expect(parsed.parts.single.title, 'New episode');
  });
}
