import 'package:huntube_app/core/providers/content_sync_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/core/providers/files_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:huntube_app/core/router/the_just_matthew_router.gr.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/elevated_button.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

@RoutePage()
class CollectionPartsScreen extends ConsumerWidget {
  const CollectionPartsScreen({
    super.key,
    required this.collection,
    required this.parts,
    required this.easterEggActivated,
  });

  final PartCollection collection;
  final List<PartFiles> parts;
  final bool easterEggActivated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(readFilesProvider).valueOrNull;
    final knownCollections =
        ref.watch(downloadedCollectionsProvider).valueOrNull ?? [];
    final currentCollection =
        knownCollections
            .where((item) => item.name == collection.name)
            .firstOrNull ??
        collection;
    final currentParts = catalog == null
        ? parts
        : catalog.where((part) => part.collection == collection).toList();
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.appColors.blackStrong,
        appBar: AppBar(
          shadowColor: context.appColors.teal,
          elevation: 10,
          backgroundColor: context.appColors.blackStrong,
          centerTitle: true,
          title: H3Text(
            text: currentCollection.title,
            textAlign: TextAlign.center,
            color: context.appColors.whiteStrong,
          ),
          leading: Tooltip(
            message: 'Vissza',
            child: ElevatedContainer(
              onTap: () => context.router.maybePop(),
              width: 30,
              height: 30,
              margin: UIConstants.paddingAll8,
              borderRadius: UIConstants.radiusAll3,
              shadowOffset: const Offset(2, 1),
              foregroundColor: context.appColors.navy,
              shadowColor: context.appColors.teal,
              child: Center(
                child: Icon(
                  Icons.arrow_back,
                  color: context.appColors.whiteStrong,
                  weight: 30,
                ),
              ),
            ),
          ),
        ),
        body: currentParts.isEmpty
            ? Center(
                child: Padding(
                  padding: UIConstants.paddingAll16,
                  child: H3Text(
                    text: 'Ebben a mappában még nincs rész.',
                    color: context.appColors.whiteStrong,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: currentParts.length,
                itemBuilder: (context, position) {
                  final part = currentParts[position];
                  return Semantics(
                    key: ValueKey(part.id),
                    button: true,
                    child: ElevatedContainer(
                      margin: UIConstants.paddingAll8,
                      borderRadius: UIConstants.radiusAll8,
                      shadowOffset: const Offset(2, 1),
                      foregroundColor: context.appColors.navy,
                      shadowColor: context.appColors.teal,
                      width: double.infinity,
                      height: 72,
                      onTap: () => context.router.push(
                        OnePartListRoute(
                          partFiles: part,
                          easterEggActivated: easterEggActivated,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: H3AutosizeText(
                            text: part.title,
                            color: context.appColors.whiteStrong,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
