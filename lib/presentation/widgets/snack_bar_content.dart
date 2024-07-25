import 'package:flutter/material.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/elevated_button.dart';
import 'package:huntube_app/presentation/widgets/texts.dart';

final class SnackAction {
  const SnackAction({
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;
}

class SuccessSnackBarContent extends StatelessWidget {
  const SuccessSnackBarContent({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedContainer(
      foregroundColor: context.appColors.greenMedium,
      padding: UIConstants.paddingAll12,
      child: B1Text(text: text),
    );
  }
}

class ErrorSnackBarContent extends StatelessWidget {
  const ErrorSnackBarContent({required this.text, this.action, super.key});

  final String text;
  final SnackAction? action;

  @override
  Widget build(BuildContext context) {
    return ElevatedContainer(
      foregroundColor: context.appColors.redStrong,
      padding: UIConstants.paddingAll12,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          B1Text(text: text),
          if (action != null)
            InkWell(
              onTap: action!.onPressed,
              child: B3Text(
                text: action!.label,
                color: context.appColors.blackStrong,
              ),
            ),
        ],
      ),
    );
  }
}
