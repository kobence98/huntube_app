import 'package:flutter/material.dart';

abstract final class UIConstants {
  static const paddingAll4 = EdgeInsets.all(4);
  static const paddingAll8 = EdgeInsets.all(8);
  static const paddingAll12 = EdgeInsets.all(12);
  static const paddingAll16 = EdgeInsets.all(16);
  static const paddingHorizontal10 = EdgeInsets.symmetric(horizontal: 10);
  static const paddingHorizontal16 = EdgeInsets.symmetric(horizontal: 16);

  static const radiusAll3 = BorderRadius.all(Radius.circular(3));
  static const radiusAll4 = BorderRadius.all(Radius.circular(4));
  static const radiusAll8 = BorderRadius.all(Radius.circular(8));
  static const radiusAll16 = BorderRadius.all(Radius.circular(16));

  static const shadowOffset4 = Offset(4, 4);
  static const shadowOffset2 = Offset(2, 2);

  static const bottomNavBarHeight = 70.0;
}
