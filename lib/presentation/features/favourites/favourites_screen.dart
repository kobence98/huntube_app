import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/core/providers/files_provider.dart';
import 'package:huntube_app/core/providers/isar_provider.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/activity_indicator.dart';
import 'package:huntube_app/presentation/widgets/elevated_button.dart';
import 'package:huntube_app/presentation/widgets/progress_bar.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

@RoutePage()
class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key, this.easterEggActivated = false});

  final bool easterEggActivated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parts = ref.watch(readFilesProvider);
    final likes = ref.watch(cachedLikesProvider);
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.appColors.blackStrong,
        appBar: AppBar(
          title: H3Text(
            text: 'Kedvencek',
            color: context.appColors.whiteStrong,
          ),
          centerTitle: true,
          backgroundColor: context.appColors.blackStrong,
          shadowColor: context.appColors.teal,
          elevation: 10,
          leading: Tooltip(
            message: 'Vissza',
            child: ElevatedContainer(
              onTap: () => context.router.maybePop(),
              margin: UIConstants.paddingAll8,
              borderRadius: UIConstants.radiusAll3,
              shadowOffset: const Offset(2, 1),
              foregroundColor: context.appColors.navy,
              shadowColor: context.appColors.teal,
              child: Icon(
                Icons.arrow_back,
                color: context.appColors.whiteStrong,
              ),
            ),
          ),
        ),
        body: parts.when(
          loading: () => const ActivityIndicator(),
          error: (_, __) => _FavouritesError(
            onRetry: () => ref.invalidate(readFilesProvider),
          ),
          data: (parts) => likes.when(
            loading: () => const ActivityIndicator(),
            error: (_, __) => _FavouritesError(
              onRetry: () => ref.invalidate(cachedLikesProvider),
            ),
            data: (likes) => _FavouriteList(
              parts: parts,
              likedIds: likes.map((like) => like.id).toSet(),
              easterEggActivated: easterEggActivated,
            ),
          ),
        ),
      ),
    );
  }
}

class _FavouriteList extends StatelessWidget {
  const _FavouriteList({
    required this.parts,
    required this.likedIds,
    required this.easterEggActivated,
  });

  final List<PartFiles> parts;
  final Set<int> likedIds;
  final bool easterEggActivated;

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[];
    for (final collection in {
      ...PartCollection.values,
      ...parts.map((part) => part.collection),
    }) {
      final sections = [
        for (final part in parts.where((part) => part.collection == collection))
          (
            part: part,
            sounds: part.files
                .where((sound) => likedIds.contains(sound.id))
                .toList(),
          ),
      ].where((section) => section.sounds.isNotEmpty).toList();
      if (sections.isEmpty) continue;
      slivers.add(
        SliverToBoxAdapter(
          key: ValueKey('collection-${collection.name}'),
          child: Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: H2Text(
                text: collection.title,
                color: context.appColors.teal,
              ),
            ),
          ),
        ),
      );
      for (final section in sections) {
        slivers.add(
          SliverToBoxAdapter(
            key: ValueKey('part-heading-${section.part.id}'),
            child: Semantics(
              header: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: H3Text(
                  text: section.part.title,
                  color: context.appColors.whiteStrong,
                ),
              ),
            ),
          ),
        );
        final indexes = {
          for (var i = 0; i < section.sounds.length; i++)
            ValueKey(section.sounds[i].id): i,
        };
        slivers.add(
          SliverList(
            key: ValueKey('part-sounds-${section.part.id}'),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProgressBar(
                key: ValueKey(section.sounds[index].id),
                fileData: section.sounds[index],
                easterEggActivated: easterEggActivated,
              ),
              childCount: section.sounds.length,
              findChildIndexCallback: (key) => indexes[key],
            ),
          ),
        );
      }
    }
    return CustomScrollView(
      slivers: slivers.isEmpty
          ? const [
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyFavourites(),
              ),
            ]
          : [...slivers, const SliverToBoxAdapter(child: SizedBox(height: 24))],
    );
  }
}

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: UIConstants.paddingAll16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 56, color: context.appColors.teal),
          const SizedBox(height: 16),
          H3Text(
            text: 'Még nincs kedvenced',
            color: context.appColors.whiteStrong,
          ),
          const SizedBox(height: 8),
          B3Text(
            text: 'Húzz jobbra egy hangot, és itt is megtalálod.',
            color: context.appColors.whiteStrong,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FavouritesError extends StatelessWidget {
  const _FavouritesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: UIConstants.paddingAll16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            H3Text(
              text: 'Nem sikerült betölteni a kedvenceket.',
              color: context.appColors.whiteStrong,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Újra')),
          ],
        ),
      ),
    );
  }
}
