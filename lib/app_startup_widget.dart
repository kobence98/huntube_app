import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/core/providers/app_startup_provider.dart';
import 'package:huntube_app/presentation/theme/app_colors.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/activity_indicator.dart';
import 'package:huntube_app/presentation/widgets/elevated_button.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';
import 'package:huntube_app/the_just_matthew_app.dart';

class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(appStartupProvider).when(
          data: (_) => MaterialApp(
            home: Scaffold(
              backgroundColor: AppColors.whiteStrong,
              body: Center(
                child: Text(
                  'IDÁIG IS ELJUT',
                  style: TextStyle(color: AppColors.blackStrong),
                ),
              ),
            ),
          ),
          error: (_, __) => _ErrorWidget(
            onRetry: () => ref.invalidate(appStartupProvider),
          ),
          loading: _LoadingWidget.new,
        );
  }
}

class _ErrorWidget extends StatefulWidget {
  const _ErrorWidget({this.onRetry});

  final VoidCallback? onRetry;

  @override
  State<_ErrorWidget> createState() => _ErrorWidgetState();
}

class _ErrorWidgetState extends State<_ErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home: Scaffold(
            body: Padding(
              padding: UIConstants.paddingHorizontal16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const H3Text(
                    text:
                        'Hiba az alkalmazás indításakor. Kérjük próbálja újra!',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TheJustMatthewElevatedButton(
                    onTap: widget.onRetry,
                    height: 40,
                    width: double.infinity,
                    child: const Center(
                      child: H3Text(
                        text: 'Újra',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
