import 'package:huntube_app/domain/models/cache/cached_like.dart';
import 'package:huntube_app/domain/models/file_data.dart';

extension FileDataX on FileData {
  CachedLike toLike() {
    return CachedLike(
      id: id,
    );
  }
}
