import 'dart:async';

import 'package:huntube_app/domain/models/file_data.dart';
import 'package:flutter/services.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/generated/assets.gen.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'files_provider.g.dart';

@riverpod
Future<List<PartFiles>> readFiles(ReadFilesRef ref) async {
  List<PartFiles> partFiles = [];

  String data = await rootBundle.loadString(Assets.textFiles.fileNames);
  int partIndex = 0;
  List<String> parts = data.split('/start/');
  parts.removeAt(0);
  for (int i = 0; i < parts.length; i++) {
    List<FileData> files = [];
    parts.elementAt(i).replaceAll('\r\n', '\n');
    List<String> lines = parts.elementAt(i).split("\n");
    lines.removeAt(0);
    lines.removeLast();
    for (int j = 1; j < lines.length; j++) {
      files.add(
        FileData(
          id: partIndex++,
          title: lines.elementAt(j++),
          assetName: lines.elementAt(j),
        ),
      );
    }
    partFiles.add(PartFiles(id: i, title: lines.first, files: files));
  }

  return partFiles;
}
