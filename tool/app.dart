import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  const platforms = {'android', 'ios', 'web', 'linux', 'windows', 'macos'};
  if (args.length < 3 ||
      !{'run', 'build'}.contains(args[0]) ||
      !platforms.contains(args[1]) ||
      !{'dev', 'staging', 'prod'}.contains(args[2])) {
    stderr.writeln(
      'Usage: dart run tool/app.dart <run|build> <platform> <dev|staging|prod> [--api=https://host] [--oauth-providers=google,github --oauth-redirect=uri] [--device=id] [--smoke]',
    );
    exitCode = 64;
    return;
  }
  final [action, platform, flavor, ...options] = args;
  String? api;
  String? device;
  String? oauthProviders;
  String? oauthRedirect;
  var smoke = false;
  for (final option in options) {
    if (option.startsWith('--api=')) {
      api = option.substring(6);
    } else if (option.startsWith('--device=')) {
      device = option.substring(9);
    } else if (option.startsWith('--oauth-providers=')) {
      oauthProviders = option.substring('--oauth-providers='.length);
    } else if (option.startsWith('--oauth-redirect=')) {
      oauthRedirect = option.substring('--oauth-redirect='.length);
    } else if (option == '--smoke') {
      smoke = true;
    } else {
      stderr.writeln('Unknown option: $option');
      exitCode = 64;
      return;
    }
  }
  if ((oauthProviders != null || oauthRedirect != null) &&
      (api == null || oauthProviders == null || oauthRedirect == null)) {
    stderr.writeln(
      'OAuth options require --api, --oauth-providers and --oauth-redirect together.',
    );
    exitCode = 64;
    return;
  }
  if (api != null) {
    final uri = Uri.tryParse(api);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path != '' && uri.path != '/')) {
      stderr.writeln('--api must be an HTTPS origin.');
      exitCode = 64;
      return;
    }
  }
  final command = <String>[action];
  if (action == 'build') {
    command.add(platform == 'android' ? 'apk' : platform);
    command.add(smoke && platform == 'android' ? '--debug' : '--release');
    if (smoke && platform == 'ios') {
      command.add('--no-codesign');
    }
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
            (d) => (d['targetPlatform'] as String? ?? '').startsWith(platform),
          )
          .toList();
      if (candidates.length != 1) {
        stderr.writeln('Connect one $platform device or pass --device=<id>.');
        exitCode = 64;
        return;
      }
      device = candidates.single['id'] as String;
    }
    command.addAll(['-d', device ?? (platform == 'web' ? 'chrome' : platform)]);
  }
  if (platform != 'web') command.addAll(['--flavor', flavor]);
  command.addAll([
    '--dart-define=FLAVOR=$flavor',
    '--dart-define=BACKEND=${api == null ? 'demo' : 'api'}',
  ]);
  if (api != null) command.add('--dart-define=API_BASE_URL=$api');
  if (oauthProviders != null) {
    command.add('--dart-define=OAUTH_PROVIDERS=$oauthProviders');
  }
  if (oauthRedirect != null) {
    command.add('--dart-define=OAUTH_REDIRECT_URI=$oauthRedirect');
  }
  final process = await Process.start(
    'flutter',
    command,
    workingDirectory: 'apps/fluent_starter',
    environment: smoke && platform == 'macos'
        ? {
            'FLUTTER_XCODE_CODE_SIGNING_ALLOWED': 'NO',
            'FLUTTER_XCODE_CODE_SIGNING_REQUIRED': 'NO',
          }
        : null,
    runInShell: Platform.isWindows,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}
