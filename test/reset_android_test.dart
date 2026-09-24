import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('Android reset CLI', () {
    late Directory fixture;
    late Directory app;
    late Directory android;
    late File script;
    late File log;

    setUp(() async {
      fixture = await Directory.systemTemp.createTemp('android reset test ');
      addTearDown(() => fixture.delete(recursive: true));
      app = await Directory('${fixture.path}/apps/fluent_starter')
          .create(recursive: true);
      android = await Directory('${app.path}/android').create();
      await Directory('${android.path}/.gradle').create();
      await File('${android.path}/.gradle/state').writeAsString('cached state');
      await File('${fixture.path}/pubspec.lock')
          .writeAsString('locked versions');
      await Directory('${fixture.path}/tool').create();
      script = await File('tool/reset_android.dart')
          .copy('${fixture.path}/tool/reset_android.dart');
      await Directory('${fixture.path}/bin').create();
      log = await File('${fixture.path}/commands.log').create();
      for (final path in [
        '${android.path}/gradlew',
        '${fixture.path}/bin/flutter',
      ]) {
        await File(path).writeAsString(r'''#!/bin/sh
printf '%s|%s\n' "$*" "$PWD" >> "$RESET_TEST_LOG"
if [ "$RESET_FAIL_COMMAND" = "$*" ]; then
  exit 23
fi
''');
        final permissions = await Process.run('chmod', ['+x', path]);
        expect(permissions.exitCode, 0, reason: '${permissions.stderr}');
      }
    });

    Future<ProcessResult> runReset({String? failCommand}) => Process.run(
      Platform.resolvedExecutable,
      [script.path],
      // The target checkout must be resolved from the script, not the caller.
      workingDirectory: Directory.systemTemp.path,
      environment: {
        'PATH': '${fixture.path}/bin:${Platform.environment['PATH']}',
        'RESET_TEST_LOG': log.path,
        'RESET_FAIL_COMMAND': failCommand ?? '',
      },
    );

    Future<void> expectBackup() async {
      expect(Directory('${android.path}/.gradle').existsSync(), isFalse);
      final backups = await Directory('${android.path}/.cache-backups')
          .list()
          .toList();
      expect(backups, hasLength(1));
      expect(
        File('${backups.single.path}/cache/state').readAsStringSync(),
        'cached state',
      );
      expect(
        File('${fixture.path}/pubspec.lock').readAsStringSync(),
        'locked versions',
      );
    }

    test('runs in order and preserves cached state in a backup', () async {
      final result = await runReset();

      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect(log.readAsLinesSync(), [
        '--stop|${android.path}',
        'clean|${app.path}',
        'pub get --enforce-lockfile|${app.path}',
      ]);
      await expectBackup();
    });

    for (final command in ['--stop', 'clean']) {
      test('stops before moving cache when $command fails', () async {
        final result = await runReset(failCommand: command);

        expect(result.exitCode, 23, reason: '${result.stderr}');
        expect(log.readAsLinesSync(), [
          '--stop|${android.path}',
          if (command == 'clean') 'clean|${app.path}',
        ]);
        expect(
          File('${android.path}/.gradle/state').readAsStringSync(),
          'cached state',
        );
        expect(
          Directory('${android.path}/.cache-backups').existsSync(),
          isFalse,
        );
      });
    }

    test('propagates pub get failure and retains the cache backup', () async {
      final result = await runReset(failCommand: 'pub get --enforce-lockfile');

      expect(result.exitCode, 23, reason: '${result.stderr}');
      await expectBackup();
    });

    test('restores dependencies when no project cache exists', () async {
      await Directory('${android.path}/.gradle').delete(recursive: true);

      final result = await runReset();

      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect(
        log.readAsLinesSync().last,
        'pub get --enforce-lockfile|${app.path}',
      );
      expect(Directory('${android.path}/.cache-backups').existsSync(), isFalse);
    });
  }, skip: Platform.isWindows ? 'Uses POSIX fake executables.' : false);
}
