import 'package:huntube_app/domain/models/cache/cached_like.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open([CachedLikeSchema], directory: dir.path);
}

@riverpod
Stream<List<CachedLike>> cachedLikes(CachedLikesRef ref) {
  return ref
      .watch(isarProvider)
      .requireValue
      .collection<CachedLike>()
      .where()
      .watch(fireImmediately: true);
}
