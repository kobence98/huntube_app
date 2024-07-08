import 'package:huntube_app/presentation/theme/app_theme.dart';
import 'package:huntube_app/core/router/the_just_matthew_router.dart';
import 'package:flutter/material.dart';

class TheJustMatthewApp extends StatefulWidget {
  const TheJustMatthewApp({super.key});

  @override
  State<TheJustMatthewApp> createState() => _TheJustMatthewAppState();
}

class _TheJustMatthewAppState extends State<TheJustMatthewApp> {
  final _router = TheJustMatthewRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router.config(),
      theme: appTheme,
    );
  }
}
