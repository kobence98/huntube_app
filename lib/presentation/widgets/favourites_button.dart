import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/presentation/theme/app_colors.dart';
import 'package:huntube_app/presentation/utils/ui_constants.dart';
import 'package:huntube_app/presentation/widgets/notifiers/elevated_button_notifier.dart';

class FavouritesButton extends ConsumerWidget {
  FavouritesButton({
    this.size,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.foregroundColor = AppColors.whiteStrong,
    this.shadowColor = AppColors.blackStrong,
    this.shadowOffset = UIConstants.shadowOffset2,
  });

  final double? size;
  final EdgeInsets margin;
  final Color foregroundColor;
  final Color shadowColor;
  final Offset shadowOffset;
  final VoidCallback? onTap;
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pushedDownButtonKey = ref.watch(elevatedButtonNotifierProvider);
    final buttonPushedDown =
        pushedDownButtonKey != null && pushedDownButtonKey == _key;
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
            () => ref
                .read(elevatedButtonNotifierProvider.notifier)
                .buttonUp(_key),
          );
        },
        child: Icon(
          Icons.favorite,
          color: foregroundColor,
          size: size,
          shadows: [
            if (!buttonPushedDown)
              Shadow(
                color: shadowColor,
                offset: shadowOffset,
                blurRadius: 5,
              )
          ],
        ),
      ),
    );
  }
}
