import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:huntube_app/domain/models/cache/cached_like.dart';
import 'package:isar_community/isar.dart';

void main() {
  setUpAll(() async {
    final packageConfigFile = File('.dart_tool/package_config.json').absolute;
    final config = jsonDecode(await packageConfigFile.readAsString())
        as Map<String, dynamic>;
    final packages = config['packages'] as List<dynamic>;
    final nativePackage = packages.cast<Map<String, dynamic>>().singleWhere(
        (package) => package['name'] == 'isar_community_flutter_libs');
    final packageRoot =
        packageConfigFile.uri.resolve(nativePackage['rootUri'] as String);
    final library = Platform.isMacOS
        ? 'macos/libisar.dylib'
        : Platform.isWindows
            ? 'windows/isar.dll'
            : 'linux/libisar.so';
    await Isar.initializeIsarCore(
      libraries: {
        Abi.current(): Directory.fromUri(packageRoot)
            .uri
            .resolve(library)
            .toFilePath(),
      },
    );
  });

  test('original Isar 3.1 favourites survive the Community upgrade and edits',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('herri-favourites-');
    addTearDown(() => directory.delete(recursive: true));
    await File('test/fixtures/isar_3_1_favourites.isar')
        .copy('${directory.path}/default.isar');

    var isar = await Isar.open(
      [CachedLikeSchema],
      directory: directory.path,
      inspector: false,
    );
    try {
      expect((await isar.cachedLikes.where().findAll()).map((like) => like.id),
          [0, 42, 149]);
      await isar.writeTxn(() async {
        await isar.cachedLikes.delete(42);
        await isar.cachedLikes.put(const CachedLike(id: 7));
      });
      await isar.close();
      isar = await Isar.open(
        [CachedLikeSchema],
        directory: directory.path,
        inspector: false,
      );
      expect((await isar.cachedLikes.where().findAll()).map((like) => like.id),
          [0, 7, 149]);
    } finally {
      await isar.close();
    }
  });
}
