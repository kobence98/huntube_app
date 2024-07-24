import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/app_startup_widget.dart';
import 'package:huntube_app/the_just_matthew_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      // child: AppStartupWidget(),
      child: const Scaffold(
        body: Center(child: Text('IDÁIG AKKOR LEFUT LEGALÁBB'),),
      ),
    ),
  );
}
