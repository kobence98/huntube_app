import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/core/providers/isar_provider.dart';
import 'package:huntube_app/domain/models/part_files.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/features/one_part_list/notifier/filter_favourites_notifier.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/activity_indicator.dart';
import 'package:huntube_app/presentation/widgets/elevated_button.dart';
import 'package:huntube_app/presentation/widgets/error_page.dart';
import 'package:huntube_app/presentation/widgets/favourites_button.dart';
import 'package:huntube_app/presentation/widgets/progress_bar.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

@RoutePage()
class OnePartListScreen extends ConsumerStatefulWidget {
  const OnePartListScreen({super.key, required this.partFiles});

  final PartFiles partFiles;

  @override
  ConsumerState<OnePartListScreen> createState() => _OnePartListScreenState();
}

class _OnePartListScreenState extends ConsumerState<OnePartListScreen> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return ref.watch(cachedLikesProvider).when(
          data: (likes) {
            final isFavouritesFilterOn =
                ref.watch(filterFavouritesNotifierProvider);
            final files = isFavouritesFilterOn
                ? widget.partFiles.files.where(
                    (file) => likes.map((like) => like.id).contains(file.id))
                : widget.partFiles.files;
            return ProviderScope(
              child: SafeArea(
                child: Scaffold(
                  appBar: AppBar(
                    shadowColor: context.appColors.teal,
                    elevation: 10,
                    backgroundColor: context.appColors.blackStrong,
                    title: new Center(
                      child: H4Text(
                        text: widget.partFiles.title,
                        textAlign: TextAlign.center,
                        color: context.appColors.whiteStrong,
                      ),
                    ),
                    leading: TheJustMatthewElevatedButton(
                      onTap: () => Future.delayed(
                        Duration(milliseconds: 300),
                        context.router.maybePop,
                      ),
                      width: 30,
                      height: 30,
                      margin: UIConstants.paddingAll8,
                      borderRadius: UIConstants.radiusAll3,
                      shadowOffset: Offset(2, 1),
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
                    actions: [
                      FavouritesButton(
                        size: 30,
                        foregroundColor: context.appColors.navy,
                        shadowColor: context.appColors.teal,
                        shadowOffset: Offset(1, 2),
                        margin: UIConstants.paddingAll8,
                        onTap: () => _filterFavourites(isFavouritesFilterOn),
                      )
                    ],
                  ),
                  body: Container(
                    color: context.appColors.blackStrong,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: files.length,
                      itemBuilder: (context, position) {
                        return ProgressBar(
                          fileData: files.elementAt(position),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
          error: (_, __) => ErrorPage(
            onRetry: () => ref.invalidate(cachedLikesProvider),
          ),
          loading: () => const ActivityIndicator(),
        );
  }

  void _filterFavourites(bool alreadyFiltered) {
    alreadyFiltered
        ? ref.read(filterFavouritesNotifierProvider.notifier).filterOff()
        : ref.read(filterFavouritesNotifierProvider.notifier).filterOn();
  }
}
