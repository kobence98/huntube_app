import 'dart:io';

Future<void> main() async {
  final toolDirectory = File.fromUri(Platform.script).parent;
  final projectDirectory = toolDirectory.parent.parent;
  final model = File(
    '${projectDirectory.path}/lib/domain/models/cache/cached_like.dart',
  );
  final stagingDirectory = Directory('${toolDirectory.path}/lib');
  stagingDirectory.createSync(recursive: true);
  model.copySync('${stagingDirectory.path}/cached_like.dart');

  for (final command in [
    ['flutter', 'pub', 'get'],
    ['dart', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
  ]) {
    final process = await Process.start(
      command.first,
      command.skip(1).toList(),
      workingDirectory: toolDirectory.path,
      mode: ProcessStartMode.inheritStdio,
    );
    final status = await process.exitCode;
    if (status != 0) exit(status);
  }

  File(
    '${stagingDirectory.path}/cached_like.g.dart',
  ).copySync('${model.parent.path}/cached_like.g.dart');
}
