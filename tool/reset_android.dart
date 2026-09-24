import 'dart:io';

/// Build maintenance only; no dependency on the workspace's package resolution.
Future<void> main(List<String> args) async {
  if (args.isNotEmpty) {
    stderr.writeln('Usage: dart tool/reset_android.dart');
    exitCode = 64;
    return;
  }
  final app = Directory.fromUri(
    Platform.script.resolve('../apps/fluent_starter/'),
  );
  final android = Directory.fromUri(app.uri.resolve('android/'));
  final wrapper = File.fromUri(
    android.uri.resolve(Platform.isWindows ? 'gradlew.bat' : 'gradlew'),
  );
  if (!wrapper.existsSync()) {
    stderr.writeln('Android Gradle wrapper not found: ${wrapper.path}');
    exitCode = 66;
    return;
  }

  try {
    var result = await runCommand(wrapper.path, ['--stop'], android);
    if (result != 0) {
      exitCode = result;
      return;
    }
    result = await runCommand('flutter', ['clean'], app);
    if (result != 0) {
      exitCode = result;
      return;
    }

    final cache = Directory.fromUri(android.uri.resolve('.gradle/'));
    if (cache.existsSync()) {
      final backups = await Directory.fromUri(
        android.uri.resolve('.cache-backups/'),
      ).create(recursive: true);
      final backup = await backups.createTemp('gradle-');
      // Keep the backup on the same filesystem for an atomic directory rename.
      final moved = await cache.rename('${backup.path}/cache');
      stdout.writeln('Gradle cache backup: ${moved.path}');
    }
    exitCode = await runCommand('flutter', [
      'pub',
      'get',
      '--enforce-lockfile',
    ], app);
  } on ProcessException catch (error) {
    stderr.writeln('Could not run ${error.executable}: ${error.message}');
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('Android cache reset failed: $error');
    exitCode = 1;
  }
}

Future<int> runCommand(
  String executable,
  List<String> arguments,
  Directory directory,
) async {
  stdout.writeln('${directory.path}: $executable ${arguments.join(' ')}');
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: directory.path,
    runInShell: Platform.isWindows,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}
