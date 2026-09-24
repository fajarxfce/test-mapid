import 'dart:io';

import 'package:yaml/yaml.dart';

Future<void> main() async {
  final root = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
  for (final directory in [
    '.',
    ...(root['workspace'] as YamlList).cast<String>(),
  ]) {
    if (!Directory('$directory/test').existsSync()) continue;
    final spec =
        loadYaml(File('$directory/pubspec.yaml').readAsStringSync()) as YamlMap;
    final deps = spec['dependencies'] as YamlMap?;
    final flutter = deps?.containsKey('flutter') ?? false;
    final result = await Process.start(
      flutter ? 'flutter' : 'dart',
      ['test', if (flutter) '--no-pub'],
      workingDirectory: directory,
      mode: ProcessStartMode.inheritStdio,
      runInShell: Platform.isWindows,
    );
    if (await result.exitCode != 0) {
      exitCode = 1;
      return;
    }
  }
}
