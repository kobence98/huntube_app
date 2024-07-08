import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huntube_app/the_just_matthew_app.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: TheJustMatthewApp(),
    ),
  );
}
