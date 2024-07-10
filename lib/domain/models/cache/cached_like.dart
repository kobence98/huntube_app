import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

part 'cached_like.g.dart';

@immutable
@collection
class CachedLike {
  const CachedLike({
    required this.id,
  });
  final Id id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CachedLike) return false;
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
