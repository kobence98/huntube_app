import 'package:huntube_app/core/providers/files_provider.dart';
import 'package:huntube_app/core/router/the_just_matthew_router.gr.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/activity_indicator.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/presentation/widgets/elevated_button.dart';
import 'package:huntube_app/presentation/widgets/error_page.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(readFilesProvider).when(
          data: (parts) {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  shadowColor: context.appColors.teal,
                  elevation: 10,
                  backgroundColor: context.appColors.blackStrong,
                  title: new Center(
                    child: H3Text(
                      text: 'R.I.P TheJustMatthew',
                      textAlign: TextAlign.center,
                      color: context.appColors.whiteStrong,
                    ),
                  ),
                ),
                backgroundColor: context.appColors.blackStrong,
                body: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: parts.length,
                  itemBuilder: (context, position) {
                    return TheJustMatthewElevatedButton(
                      margin: UIConstants.paddingAll8,
                      borderRadius: UIConstants.radiusAll8,
                      shadowOffset: Offset(2, 1),
                      foregroundColor: context.appColors.navy,
                      shadowColor: context.appColors.teal,
                      width: double.infinity,
                      height: 60,
                      child: Center(
                        child: H3AutosizeText(
                          text: parts.elementAt(position).title,
                          color: context.appColors.whiteStrong,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onTap: () => Future.delayed(
                        Duration(milliseconds: 200),
                        () => context.router.push(
                          OnePartListRoute(
                            partFiles: parts.elementAt(position),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          error: (error, stackTrace) => ErrorPage(onRetry: () => ref.invalidate(readFilesProvider)),
          loading: ActivityIndicatorApp.new,
        );
  }
}
