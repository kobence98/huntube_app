import 'package:flutter/services.dart';
import 'package:huntube_app/core/providers/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_startup_provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> appStartup(AppStartupRef ref) async {
  ref.onDispose(() {
    ref.invalidate(isarProvider);
  });

  await Future.wait(
    [
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    ],
  );

  await ref.watch(isarProvider.future);
}
