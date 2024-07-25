import 'package:flutter/material.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/elevated_button.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({this.onRetry});

  final VoidCallback? onRetry;

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
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
