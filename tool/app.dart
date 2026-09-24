import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  const platforms = {'android', 'ios', 'web'};
  if (args.length < 3 ||
      !{'run', 'build'}.contains(args[0]) ||
      !platforms.contains(args[1]) ||
      !{'dev', 'staging', 'prod'}.contains(args[2])) {
    stderr.writeln(
      'Usage: dart run tool/app.dart <run|build> <android|ios|web> <dev|staging|prod> [--device=id] [--smoke]',
    );
    exitCode = 64;
    return;
  }
  final [action, platform, flavor, ...options] = args;
  String? device;
  var smoke = false;
  for (final option in options) {
    if (option.startsWith('--device=')) {
      device = option.substring('--device='.length);
    } else if (option == '--smoke') {
      smoke = true;
    } else {
      stderr.writeln('Unknown option: $option');
      exitCode = 64;
      return;
    }
  }
  final environment = File.fromUri(Platform.script.resolve('../.env'));
  if (!environment.existsSync()) {
    stderr.writeln(
      'Create the root .env from .env.example and populate the MAPID configuration.',
    );
    exitCode = 78;
    return;
  }
  final command = <String>[action];
  if (action == 'build') {
    command.add(platform == 'android' ? 'apk' : platform);
    command.add(smoke && platform == 'android' ? '--debug' : '--release');
    if (smoke && platform == 'ios') command.add('--no-codesign');
  } else {
    if (device == null && {'android', 'ios'}.contains(platform)) {
      final result = await Process.run('flutter', [
        'devices',
        '--machine',
      ], runInShell: Platform.isWindows);
      if (result.exitCode != 0) {
        stderr.write(result.stderr);
        exitCode = result.exitCode;
        return;
      }
      final devices = (jsonDecode(result.stdout as String) as List)
          .cast<Map<String, dynamic>>();
      final candidates = devices
          .where(
            (entry) =>
                (entry['targetPlatform'] as String? ?? '').startsWith(platform),
          )
          .toList();
      if (candidates.length != 1) {
        stderr.writeln('Connect one $platform device or pass --device=<id>.');
        exitCode = 64;
        return;
      }
      device = candidates.single['id'] as String;
    }
    command.addAll(['-d', device ?? 'chrome']);
  }
  if (platform != 'web') command.addAll(['--flavor', flavor]);
  command.addAll([
    '--dart-define-from-file=${environment.path}',
    '--dart-define=FLAVOR=$flavor',
  ]);
  final process = await Process.start(
    'flutter',
    command,
    workingDirectory: Directory.fromUri(
      Platform.script.resolve('../apps/fluent_starter/'),
    ).path,
    runInShell: Platform.isWindows,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}
