
import 'package:flutter/material.dart';

@immutable
class FileData {
  FileData({
    required this.id,
    required this.title,
    required this.assetName,
    this.liked = false
  });

  final int id;
  final String title;
  final String assetName;
  final bool liked;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FileData) return false;
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
