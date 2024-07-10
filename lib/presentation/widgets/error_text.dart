import 'package:flutter/material.dart';
import 'package:huntube_app/presentation/extensions/context_extensions.dart';

class ErrorText extends StatelessWidget {
  const ErrorText({super.key, this.errorText});

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutSine,
        opacity: errorText == null ? 0 : 1,
        child: Text(
          errorText ?? '',
          textScaler: TextScaler.noScaling,
          style: context.textStyles.b1.copyWith(
            height: 1,
            color: const Color(0xFFC73717),
          ),
        ),
      ),
    );
  }
}
