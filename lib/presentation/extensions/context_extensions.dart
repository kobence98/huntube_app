import 'package:huntube_app/presentation/theme/the_just_matthew_colors.dart';
import 'package:huntube_app/presentation/theme/the_just_matthew_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:huntube_app/presentation/widgets/snack_bar_content.dart';

extension BuildContextX on BuildContext {
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;
  double get topPadding => MediaQuery.paddingOf(this).top;
  double get bottomPadding {
    final padding = MediaQuery.paddingOf(this).bottom;
    return padding == 0 ? 8 : padding;
  }

  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  ThemeData get theme => Theme.of(this);
  TheJustMatthewColors get appColors => theme.extension<TheJustMatthewColors>()!;

  TheJustMatthewTextStyles get textStyles =>
      Theme.of(this).extension<TheJustMatthewTextStyles>()!;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
    required String text,
    SnackAction? action,
    bool isSuccess = false,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        content: isSuccess
            ? SuccessSnackBarContent(text: text)
            : ErrorSnackBarContent(text: text, action: action),
      ),
    );
  }
}
