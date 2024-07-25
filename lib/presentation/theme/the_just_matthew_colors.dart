import 'package:huntube_app/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

@immutable
class TheJustMatthewColors extends ThemeExtension<TheJustMatthewColors> {
  const TheJustMatthewColors({
    required this.blackStrong,
    required this.navy,
    required this.teal,
    required this.indigo,
    required this.whiteStrong,
    required this.redStrong,
    required this.greenMedium,
  });
  final Color blackStrong;
  final Color navy;
  final Color teal;
  final Color indigo;
  final Color whiteStrong;
  final Color redStrong;
  final Color greenMedium;

  static const standard = TheJustMatthewColors(
    blackStrong: AppColors.blackStrong,
    navy: AppColors.navy,
    teal: AppColors.teal,
    indigo: AppColors.indigo,
    whiteStrong: AppColors.whiteStrong,
    redStrong: AppColors.redStrong,
    greenMedium: AppColors.greenMedium,
  );

  @override
  ThemeExtension<TheJustMatthewColors> copyWith({
    Color? blackStrong,
    Color? navy,
    Color? teal,
    Color? indigo,
    Color? whiteStrong,
    Color? redStrong,
    Color? greenMedium,
  }) {
    return TheJustMatthewColors(
      blackStrong: blackStrong ?? this.blackStrong,
      navy: navy ?? this.navy,
      teal: teal ?? this.teal,
      indigo: indigo ?? this.indigo,
      whiteStrong: whiteStrong ?? this.whiteStrong,
      redStrong: redStrong ?? this.redStrong,
      greenMedium: greenMedium ?? this.greenMedium,
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
      indigo: Color.lerp(indigo, other.indigo, t) ?? indigo,
      whiteStrong: Color.lerp(whiteStrong, other.whiteStrong, t) ?? whiteStrong,
      redStrong: Color.lerp(redStrong, other.redStrong, t) ?? redStrong,
      greenMedium: Color.lerp(greenMedium, other.greenMedium, t) ?? greenMedium,
    );
  }
}
