import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/core/providers/content_sync_provider.dart';

class ContentSyncButton extends ConsumerWidget {
  const ContentSyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(contentSyncProvider);
    return IconButton(
      tooltip: sync.running
          ? 'Hangok letöltése: ${sync.completed}/${sync.total}'
          : 'Új hangok keresése',
      onPressed: () => showDialog<void>(
        context: context,
        builder: (context) => const _ContentSyncDialog(),
      ),
      icon: sync.running
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_download_outlined),
    );
  }
}

class _ContentSyncDialog extends ConsumerWidget {
  const _ContentSyncDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(contentSyncProvider);
    return AlertDialog(
      title: const Text('Offline hangok'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Az eredeti hangok az app részei. Az új hangokat induláskor '
            'automatikusan letöltjük, utána internet nélkül is lejátszhatók. '
            'A letöltés mobiladatot is használhat.',
          ),
          const SizedBox(height: 16),
          if (sync.running) ...[
            LinearProgressIndicator(
              value: sync.total == 0 ? null : sync.completed / sync.total,
            ),
            const SizedBox(height: 8),
            Text(
              sync.total == 0
                  ? 'Új hangok keresése…'
                  : 'Hangok ellenőrzése és letöltése: ${sync.completed}/${sync.total}',
            ),
          ] else if (sync.message != null)
            Text(sync.message!),
        ],
      ),
      actions: [
        TextButton(
          onPressed: sync.running
              ? null
              : () => unawaited(ref.read(contentSyncProvider.notifier).sync()),
          child: const Text('Frissítés'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Bezárás'),
        ),
      ],
    );
  }
}
