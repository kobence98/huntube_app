import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/theme/app_colors.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/notifiers/elevated_button_notifier.dart';

class ElevatedContainer extends ConsumerWidget {
  ElevatedContainer({
    this.width,
    this.height,
    this.child,
    this.padding,
    this.borderRadius = UIConstants.radiusAll3,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.foregroundColor = AppColors.whiteStrong,
    this.shadowColor = AppColors.blackStrong,
    this.shadowOffset = UIConstants.shadowOffset2,
  });

  final double? width;
  final double? height;
  final Widget? child;
  final EdgeInsets margin;
  final EdgeInsets? padding;
  final BorderRadius borderRadius;
  final Color foregroundColor;
  final Color shadowColor;
  final Offset shadowOffset;
  final VoidCallback? onTap;
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pushedDownButtonKey = ref.watch(elevatedButtonNotifierProvider);
    final buttonPushedDown = pushedDownButtonKey != null && pushedDownButtonKey == _key;
    return Padding(
      padding: EdgeInsets.only(
        top: margin.top + (buttonPushedDown ? shadowOffset.dy : 0),
        bottom: margin.bottom - (buttonPushedDown ? shadowOffset.dy : 0),
        left: margin.left + (buttonPushedDown ? shadowOffset.dx : 0),
        right: margin.right - (buttonPushedDown ? shadowOffset.dx : 0),
      ),
      child: GestureDetector(
        onTap: onTap,
        onTapDown: (_) =>
            ref.read(elevatedButtonNotifierProvider.notifier).buttonDown(_key),
        onTapUp: (_) {
          Future.delayed(
            Duration(milliseconds: 150),
            () => ref.read(elevatedButtonNotifierProvider.notifier).buttonUp(_key),
          );
        },
        child: Container(
          width: width,
          height: height,
          padding: padding,
          margin: EdgeInsets.only(
            right: shadowOffset.dx,
            bottom: shadowOffset.dy,
          ),
          decoration: BoxDecoration(
            color: foregroundColor,
            borderRadius: borderRadius,
            boxShadow: [
              if (!buttonPushedDown)
                BoxShadow(
                  color: shadowColor,
                  offset: shadowOffset,
                  blurRadius: 5,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
