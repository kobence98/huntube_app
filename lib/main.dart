import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/app_startup_widget.dart';
import 'package:huntube_app/presentation/theme/app_colors.dart';
import 'package:huntube_app/the_just_matthew_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      // child: AppStartupWidget(),
      child: MaterialApp(
          home: Scaffold(
          backgroundColor: AppColors.whiteStrong,
          body: Center(
            child: Text(
              'IDÁIG LEGALÁBB ELJUT',
              style: TextStyle(color: AppColors.blackStrong),
            ),
          ),
        ),
      ),
    ),
  );
}
