import 'package:flutter/material.dart';

class TappableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AppBar appBar;

  const TappableAppBar({
    required this.appBar,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: appBar, onLongPress: onLongPress,);
  }

  @override
  Size get preferredSize => appBar.preferredSize;
}
