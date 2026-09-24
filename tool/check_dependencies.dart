import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// All hosted dependency versions belong to the root overrides file.
List<String> checkDependencies(Directory root) {
  YamlMap read(String path) =>
      loadYaml(File(p.join(root.path, path)).readAsStringSync()) as YamlMap;

  final errors = <String>[];
  final rootSpec = read('pubspec.yaml');
  final specs = <String, YamlMap>{
    '.': rootSpec,
    for (final directory in (rootSpec['workspace'] as YamlList).cast<String>())
      directory: read('$directory/pubspec.yaml'),
  };
  final workspaceNames = specs.values.map((spec) => spec['name']).toSet();
  final overridesFile = File(p.join(root.path, 'pubspec_overrides.yaml'));
  if (!overridesFile.existsSync()) {
    return ['root: missing shared pubspec_overrides.yaml'];
  }
  final overrides = read('pubspec_overrides.yaml')['dependency_overrides'];
  if (overrides is! YamlMap) {
    return ['root: dependency_overrides must be a version mapping'];
  }
  for (final entry in overrides.entries) {
    final version = entry.value;
    if (version is! String || version.trim().isEmpty || version == 'any') {
      errors.add('root: ${entry.key} needs a shared version constraint');
    }
    if (workspaceNames.contains(entry.key)) {
      errors.add('root: ${entry.key} must resolve through the workspace');
    }
  }
  for (final entry in specs.entries) {
    final directory = entry.key;
    final spec = entry.value;
    if (spec.containsKey('dependency_overrides')) {
      errors.add(
        '$directory: move dependency_overrides to the root overrides file',
      );
    }
    if (directory != '.') {
      final localFile = File(
        p.join(root.path, directory, 'pubspec_overrides.yaml'),
      );
      if (localFile.existsSync() &&
          read('$directory/pubspec_overrides.yaml')
              .containsKey('dependency_overrides')) {
        errors.add('$directory: local dependency_overrides are not allowed');
      }
    }
    for (final section in ['dependencies', 'dev_dependencies']) {
      final dependencies = spec[section] as YamlMap? ?? YamlMap();
      for (final dependency in dependencies.entries) {
        final name = dependency.key as String;
        final declaration = dependency.value;
        if (declaration is YamlMap && declaration['sdk'] != null) {
          if (overrides.containsKey(name)) {
            errors.add(
              '$directory: SDK dependency $name must not be overridden',
            );
          }
          continue;
        }
        if (declaration != 'any') {
          errors.add(
            '$directory: declare $name as any; keep versions in root overrides',
          );
        }
        if (!workspaceNames.contains(name) && !overrides.containsKey(name)) {
          errors.add(
            '$directory: $name is missing from root dependency_overrides',
          );
        }
      }
    }
  }
  return errors;
}

void main() {
  final errors = checkDependencies(Directory.current);
  if (errors.isNotEmpty) {
    stderr.writeln(errors.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln('Dependency version policy passed.');
}
