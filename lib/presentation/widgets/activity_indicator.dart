import 'package:huntube_app/presentation/extensions/context_extensions.dart';
import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget activityIndicatorBuilder(BuildContext context) {
  return const ActivityIndicator();
}

class ActivityIndicatorApp extends StatelessWidget {
  const ActivityIndicatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const Scaffold(
        body: ActivityIndicator(),
      ),
    );
  }
}

class ActivityIndicator extends StatelessWidget {
  const ActivityIndicator({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(strokeWidth: 2, color: context.appColors.teal,),
      ),
    );
  }
}
