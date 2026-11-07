import 'package:flutter/material.dart';
import 'package:huntube_app/domain/models/file_data.dart';
import 'package:huntube_app/domain/models/part_collection.dart';

@immutable
class PartFiles {
  const PartFiles({
    required this.id,
    required this.title,
    required this.files,
    this.collection = PartCollection.herri,
  });

  final PartCollection collection;
  final int id;
  final String title;
  final List<FileData> files;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FileData) return false;
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
