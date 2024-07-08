import 'package:huntube_app/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:huntube_app/presentation/theme/the_just_matthew_colors.dart';
import 'package:huntube_app/presentation/theme/the_just_matthew_text_styles.dart';

final appTheme = ThemeData(
  primaryColor: AppColors.blackStrong,
  extensions: const [
    TheJustMatthewColors.standard,
    TheJustMatthewTextStyles.standard,
  ],
);
