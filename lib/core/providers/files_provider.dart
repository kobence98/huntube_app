import 'package:huntube_app/core/providers/content_sync_provider.dart';
import 'dart:async';

import 'package:huntube_app/domain/models/file_data.dart';
import 'package:flutter/services.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:huntube_app/generated/assets.gen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'files_provider.g.dart';

@riverpod
Future<List<PartFiles>> readFiles(ReadFilesRef ref) async {
  final data = await rootBundle.loadString(Assets.textFiles.fileNames);
  final sections = data
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('/start/')
      .skip(1);
  final parts = <PartFiles>[];
  var soundId = 0;

  for (final section in sections) {
    final lines = section.trim().split('\n');
    final title = lines.first;
    var firstSoundLine = 1;
    var collection = PartCollection.herri;
    if (lines.length > 1 && lines[1].startsWith('/collection/')) {
      final name = lines[1].substring('/collection/'.length);
      collection = PartCollection.values.firstWhere(
        (value) => value.name == name,
      );
      firstSoundLine++;
    }
    if ((lines.length - firstSoundLine).isOdd) {
      throw FormatException('Incomplete sound entry in $title');
    }
    final files = <FileData>[];
    for (var i = firstSoundLine; i < lines.length; i += 2) {
      files.add(
        FileData(id: soundId++, title: lines[i], assetName: lines[i + 1]),
      );
    }
    parts.add(
      PartFiles(
        id: parts.length,
        title: title,
        files: files,
        collection: collection,
      ),
    );
  }
  final downloaded = await ref.watch(downloadedPartsProvider.future);
  return [...parts, ...downloaded];
}
