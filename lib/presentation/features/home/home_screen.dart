import 'package:huntube_app/core/providers/content_sync_provider.dart';
import 'package:huntube_app/presentation/widgets/content_sync_button.dart';
import 'package:huntube_app/core/providers/files_provider.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:huntube_app/core/router/the_just_matthew_router.gr.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/activity_indicator.dart';
import 'package:huntube_app/presentation/widgets/app_info_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/presentation/widgets/elevated_button.dart';
import 'package:huntube_app/presentation/widgets/error_page.dart';
import 'package:huntube_app/presentation/widgets/tappable_app_bar.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int tapNumber = 0;
  bool easterEggActivated = false;

  @override
  Widget build(BuildContext context) {
    final remoteCollections =
        ref.watch(downloadedCollectionsProvider).valueOrNull ?? [];
    return ref
        .watch(readFilesProvider)
        .when(
          data: (parts) {
            final collections = {
              ...PartCollection.values,
              ...remoteCollections,
              ...parts.map((part) => part.collection),
            }.toList();
            return SafeArea(
              child: Scaffold(
                appBar: TappableAppBar(
                  onTap: () {
                    if (++tapNumber == 10) {
                      easterEggActivated = true;
                      context.showSnackBar(
                        text: 'Aktiváltad az easter egget! Jó szórakozást!:)',
                        isSuccess: true,
                      );
                    } else if (tapNumber > 13) {
                      context.showSnackBar(
                        text:
                            'Már aktiváltad az easter egget, ne legyél mohó!:)',
                      );
                    }
                  },
                  onLongPress: () {
                    if (easterEggActivated) {
                      easterEggActivated = false;
                      tapNumber = 0;
                      context.showSnackBar(
                        text: 'Visszakapcsoltad a normál módot!',
                      );
                    }
                  },
                  appBar: AppBar(
                    shadowColor: context.appColors.teal,
                    elevation: 10,
                    backgroundColor: context.appColors.blackStrong,
                    actions: [
                      const ContentSyncButton(),
                      IconButton(
                        tooltip: 'Összes kedvenc',
                        color: context.appColors.teal,
                        icon: const Icon(Icons.favorite),
                        onPressed: () => context.router.push(
                          FavouritesRoute(
                            easterEggActivated: easterEggActivated,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Segítség és adatvédelem',
                        color: context.appColors.whiteStrong,
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (context) => const AppInfoDialog(),
                        ),
                      ),
                    ],
                    title: Center(
                      child: H3Text(
                        text: 'R.I.P TheJustMatthew',
                        textAlign: TextAlign.center,
                        color: context.appColors.whiteStrong,
                      ),
                    ),
                  ),
                ),
                backgroundColor: context.appColors.blackStrong,
                body: ListView.builder(
                  padding: const EdgeInsets.only(top: 10.0),
                  itemCount: collections.length,
                  itemBuilder: (context, position) {
                    return ElevatedContainer(
                      margin: UIConstants.paddingAll8,
                      borderRadius: UIConstants.radiusAll8,
                      shadowOffset: const Offset(2, 1),
                      foregroundColor: context.appColors.navy,
                      shadowColor: context.appColors.teal,
                      width: double.infinity,
                      height: 64,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Center(
                        child: H3AutosizeText(
                          text: collections[position].title,
                          color: context.appColors.whiteStrong,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onTap: () =>
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (!context.mounted) return;
                            final collection = collections[position];
                            context.router.push(
                              CollectionPartsRoute(
                                collection: collection,
                                parts: parts
                                    .where(
                                      (part) => part.collection == collection,
                                    )
                                    .toList(),
                                easterEggActivated: easterEggActivated,
                              ),
                            );
                          }),
                    );
                  },
                ),
              ),
            );
          },
          error: (error, stackTrace) =>
              ErrorPage(onRetry: () => ref.invalidate(readFilesProvider)),
          loading: ActivityIndicatorApp.new,
        );
  }
}
