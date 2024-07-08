import 'package:huntube_app/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

@immutable
class TheJustMatthewColors extends ThemeExtension<TheJustMatthewColors> {
  const TheJustMatthewColors({
    required this.blackStrong,
    required this.navy,
    required this.teal,
    required this.whiteStrong,
  });
  final Color blackStrong;
  final Color navy;
  final Color teal;
  final Color whiteStrong;

  static const standard = TheJustMatthewColors(
    blackStrong: AppColors.blackStrong,
    navy: AppColors.navy,
    teal: AppColors.teal,
    whiteStrong: AppColors.whiteStrong,
  );

  @override
  ThemeExtension<TheJustMatthewColors> copyWith({
    Color? blackStrong,
    Color? navy,
    Color? teal,
    Color? whiteStrong,
  }) {
    return TheJustMatthewColors(
      blackStrong: blackStrong ?? this.blackStrong,
      navy: navy ?? this.navy,
      teal: teal ?? this.teal,
      whiteStrong: whiteStrong ?? this.whiteStrong,
    );
  }

  @override
  ThemeExtension<TheJustMatthewColors> lerp(
    covariant ThemeExtension<TheJustMatthewColors>? other,
    double t,
  ) {
    if (other is! TheJustMatthewColors) return this;
    return TheJustMatthewColors(
      blackStrong: Color.lerp(blackStrong, other.blackStrong, t) ?? blackStrong,
      navy: Color.lerp(navy, other.navy, t) ?? navy,
      teal: Color.lerp(teal, other.teal, t) ?? teal,
      whiteStrong: Color.lerp(whiteStrong, other.whiteStrong, t) ?? whiteStrong,
    );
  }
}
