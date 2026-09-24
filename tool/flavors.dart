import 'dart:io';

/// Flavorizr 2.6 drops Flutter's SPM preparation/build actions in new schemes.
/// Preserve the SDK's Runner scheme and vary only its build configurations.
void repairAppleSchemes(Directory app) {
  for (final platform in ['ios', 'macos']) {
    final directory =
        '${app.path}/$platform/Runner.xcodeproj/xcshareddata/xcschemes';
    final template = File('$directory/Runner.xcscheme').readAsStringSync();
    for (final flavor in ['dev', 'staging', 'prod']) {
      var scheme = template;
      for (final mode in ['Debug', 'Profile', 'Release']) {
        scheme = scheme.replaceAll(
          'buildConfiguration = "$mode"',
          'buildConfiguration = "$mode-$flavor"',
        );
      }
      File('$directory/$flavor.xcscheme').writeAsStringSync(scheme);
    }
  }
}

Future<void> main(List<String> args) async {
  final app = Directory('apps/fluent_starter');
  if (!args.contains('--repair-only')) {
    final process = await Process.start(
      'dart',
      ['run', 'flutter_flavorizr', '-f'],
      workingDirectory: app.path,
      runInShell: Platform.isWindows,
      mode: ProcessStartMode.inheritStdio,
    );
    final code = await process.exitCode;
    if (code != 0) {
      exitCode = code;
      return;
    }
  }
  repairAppleSchemes(app);
}
