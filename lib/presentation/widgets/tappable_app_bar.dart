import 'package:flutter/material.dart';

class TappableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AppBar appBar;

  const TappableAppBar({
    super.key,
    required this.appBar,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: appBar,
    );
  }

  @override
  Size get preferredSize => appBar.preferredSize;
}
