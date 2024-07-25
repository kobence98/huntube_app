import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/core/providers/app_startup_provider.dart';
import 'package:huntube_app/presentation/theme/app_colors.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:huntube_app/presentation/widgets/activity_indicator.dart';
import 'package:huntube_app/presentation/widgets/error_page.dart';
import 'package:huntube_app/the_just_matthew_app.dart';

class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(appStartupProvider).when(
          data: (_) => const TheJustMatthewApp(),
          error: (_, __) => ErrorPage(
            onRetry: () => ref.invalidate(appStartupProvider),
          ),
          loading: _LoadingWidget.new,
        );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const Scaffold(
        backgroundColor: AppColors.blackStrong,
        body: ActivityIndicator(),
      ),
    );
  }
}
