import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/data/content/content_store.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:path_provider/path_provider.dart';

const contentManifestUrl = String.fromEnvironment(
  'CONTENT_MANIFEST_URL',
  defaultValue:
      'https://docs.google.com/document/d/1Z7ueja_ALWhbyCWf1mn-OMV8OURkKJGzkWXpVak01xg/export?format=txt',
);

final contentStoreProvider = FutureProvider<ContentStore>((ref) async {
  final directory = await getApplicationSupportDirectory();
  return ContentStore(
    directory: Directory('${directory.path}/downloaded_content'),
    manifestUri: Uri.parse(contentManifestUrl),
  );
});

final downloadedPartsProvider = FutureProvider<List<PartFiles>>((ref) async {
  try {
    return await (await ref.watch(contentStoreProvider.future)).loadCached();
  } catch (_) {
    // Bundled content remains available even if local storage is unavailable.
    return [];
  }
});

final downloadedCollectionsProvider = FutureProvider<List<PartCollection>>((
  ref,
) async {
  try {
    return await (await ref.watch(
      contentStoreProvider.future,
    )).loadCachedCollections();
  } catch (_) {
    return [];
  }
});

class ContentSyncState {
  const ContentSyncState({
    this.running = false,
    this.completed = 0,
    this.total = 0,
    this.message,
  });

  final bool running;
  final int completed;
  final int total;
  final String? message;
}

final contentSyncProvider =
    StateNotifierProvider<ContentSyncNotifier, ContentSyncState>(
      (ref) => ContentSyncNotifier(ref),
    );

class ContentSyncNotifier extends StateNotifier<ContentSyncState> {
  ContentSyncNotifier(this.ref) : super(const ContentSyncState());

  final Ref ref;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await sync();
  }

  Future<void> sync() async {
    if (state.running) return;
    state = const ContentSyncState(running: true);
    try {
      final store = await ref.read(contentStoreProvider.future);
      await store.sync(
        onProgress: (completed, total) {
          if (!mounted) return;
          state = ContentSyncState(
            running: true,
            completed: completed,
            total: total,
          );
        },
      );
      if (!mounted) return;
      ref.invalidate(downloadedPartsProvider);
      ref.invalidate(downloadedCollectionsProvider);
      state = const ContentSyncState(message: 'A hangok naprakészek.');
    } catch (_) {
      if (!mounted) return;
      state = const ContentSyncState(
        message:
            'A frissítés most nem sikerült. A meglévő hangok offline is elérhetők.',
      );
    }
  }
}
