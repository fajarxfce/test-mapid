import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/check_dependencies.dart';

void main() {
  late Directory root;
  void write(String path, String source) {
    final file = File(p.join(root.path, path));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('dependencies_');
    write('pubspec.yaml', '''
name: workspace
workspace: [core, app]
dev_dependencies: {test: any}
''');
    write('pubspec_overrides.yaml', '''
dependency_overrides: {dio: ^5.9.0, test: ^1.26.0}
''');
    write('core/pubspec.yaml', 'name: core\n');
    write('app/pubspec.yaml', '''
name: app
dependencies:
  core: any
  dio: any
  flutter: {sdk: flutter}
dev_dependencies:
  flutter_test: {sdk: flutter}
''');
  });
  tearDown(() => root.deleteSync(recursive: true));

  test('accepts shared hosted versions, SDK and workspace resolution', () {
    expect(checkDependencies(root), isEmpty);
  });
  test('rejects a missing catalog', () {
    File(p.join(root.path, 'pubspec_overrides.yaml')).deleteSync();
    expect(checkDependencies(root), contains(contains('missing shared')));
  });
  test('rejects repeated package versions and missing shared dependencies', () {
    write('app/pubspec.yaml', '''
name: app
dependencies: {dio: ^5.9.0}
dev_dependencies: {mocktail: any}
''');
    final errors = checkDependencies(root);
    expect(errors, contains(contains('declare dio as any')));
    expect(errors, contains(contains('mocktail is missing')));
  });
  test('rejects overrides in root and member pubspecs or local files', () {
    for (final path in ['pubspec.yaml', 'app/pubspec.yaml']) {
      File(p.join(root.path, path)).writeAsStringSync(
        'dependency_overrides: {dio: ^5.9.1}\n',
        mode: FileMode.append,
      );
    }
    write(
      'app/pubspec_overrides.yaml',
      'dependency_overrides: {dio: ^5.9.1}\n',
    );
    final errors = checkDependencies(root);
    expect(
      errors.where((error) => error.contains('move dependency_overrides')),
      hasLength(2),
    );
    expect(errors, contains(contains('local dependency_overrides')));
  });
  test('allows local workspace configuration without dependency overrides', () {
    write('app/pubspec_overrides.yaml', 'resolution: workspace\n');
    expect(checkDependencies(root), isEmpty);
  });
  test('requires shared constraints and preserves SDK/workspace sources', () {
    write('pubspec_overrides.yaml', '''
dependency_overrides:
  dio: any
  test: {version: ^1.26.0}
  core: ^1.0.0
  flutter: ^1.0.0
''');
    final errors = checkDependencies(root);
    expect(errors, contains(contains('dio needs a shared version constraint')));
    expect(
      errors,
      contains(contains('test needs a shared version constraint')),
    );
    expect(
      errors,
      contains(contains('core must resolve through the workspace')),
    );
    expect(
      errors,
      contains(contains('SDK dependency flutter must not be overridden')),
    );
  });
}
