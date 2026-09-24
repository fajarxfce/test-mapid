import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'bloc_architecture_visitor.dart';
import 'ui_architecture_visitor.dart';

const allowed = <String, Set<String>>{
  'core_common': {},
  'core_network': {'core_common'},
  'core_design_system': {},
  'core_location_domain': {'core_common'},
  'core_location_data': {'core_common', 'core_location_domain'},
  'map_domain': {'core_common'},
  'map_data': {'map_domain', 'core_common', 'core_network'},
  'map_presentation': {
    'map_domain',
    'core_common',
    'core_design_system',
    'core_location_domain',
  },
  'fluent_starter': {
    'core_network',
    'core_location_domain',
    'core_location_data',
    'core_design_system',
    'map_domain',
    'map_data',
    'map_presentation',
  },
};

List<String> checkArchitecture(Directory root) {
  final errors = <String>[];
  final spec = loadYaml(
    File(p.join(root.path, 'pubspec.yaml')).readAsStringSync(),
  ) as YamlMap;
  final packages = <String, ({String directory, YamlMap spec})>{};
  for (final entry in (spec['workspace'] as YamlList).cast<String>()) {
    final directory = p.normalize(p.absolute(root.path, entry));
    final data = loadYaml(
      File(p.join(directory, 'pubspec.yaml')).readAsStringSync(),
    ) as YamlMap;
    packages[data['name'] as String] = (directory: directory, spec: data);
  }
  final graph = <String, Set<String>>{};
  for (final entry in packages.entries) {
    final name = entry.key;
    final package = entry.value;
    final pure = name.endsWith('_domain') || name == 'core_common';
    final dependencies =
        (package.spec['dependencies'] as YamlMap?) ?? YamlMap();
    graph[name] = dependencies.keys
        .cast<String>()
        .where(packages.containsKey)
        .toSet();
    if (!allowed.containsKey(name)) {
      errors.add('$name: register an explicit dependency policy');
    }
    for (final dep in graph[name]!) {
      if (!(allowed[name]?.contains(dep) ?? false)) {
        errors.add('$name: forbidden dependency $dep');
      }
    }
    if (pure && dependencies.keys.any((key) => key != 'core_common')) {
      errors.add(
        '$name: domain/common may depend only on Dart SDK and core_common',
      );
    }
    final lib = Directory(p.join(package.directory, 'lib'));
    if (!lib.existsSync()) continue;
    for (final file
        in lib
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final unit = parseString(
        content: file.readAsStringSync(),
        throwIfDiagnostics: false,
      ).unit;
      final relativePath = p.posix.joinAll(
        p.split(p.relative(file.path, from: lib.path)),
      );
      if (name.endsWith('_presentation') &&
          relativePath != '$name.dart' &&
          !relativePath.startsWith('src/') &&
          !relativePath.startsWith('di/')) {
        errors.add(
          '$name/$relativePath: presentation features belong in lib/src; '
          'keep DI in lib/di',
        );
      }
      final ui =
          relativePath == 'app.dart' ||
          p.posix
              .split(relativePath)
              .any({'pages', 'views', 'widgets'}.contains);
      final generated = RegExp(r'\.(g|gr|freezed|config|module)\.dart$')
          .hasMatch(file.path);
      if (relativePath == '$name.dart' &&
          (unit.declarations.isNotEmpty ||
              unit.directives.any(
                (directive) =>
                    directive is! ExportDirective &&
                    directive is! LibraryDirective,
              ))) {
        errors.add('$name: package entrypoint must contain only exports');
      }
      if (!generated) {
        unit.accept(
          BlocArchitectureVisitor(
            (message) => errors.add('$name/$relativePath: $message'),
          ),
        );
        final publicTypes = unit.declarations
            .map(
              (declaration) => switch (declaration) {
                ClassDeclaration() => declaration.namePart.typeName.lexeme,
                EnumDeclaration() => declaration.namePart.typeName.lexeme,
                ExtensionTypeDeclaration() =>
                  declaration.namePart.typeName.lexeme,
                MixinDeclaration() => declaration.name.lexeme,
                ExtensionDeclaration() => declaration.name?.lexeme,
                _ => null,
              },
            )
            .whereType<String>()
            .where((name) => !name.startsWith('_'))
            .toList();
        if (publicTypes.length > 1 &&
            !_isSealedFamily(unit, publicTypes.length)) {
          errors.add(
            '$name/$relativePath: split public types into separate files: '
            '${publicTypes.join(', ')}',
          );
        }
      }
      final uris = <String>[];
      for (final directive in unit.directives) {
        if (directive is UriBasedDirective) {
          final uri = directive.uri.stringValue;
          if (uri != null) uris.add(uri);
        }
        if (directive is NamespaceDirective) {
          uris.addAll(
            directive.configurations
                .map((c) => c.uri.stringValue)
                .whereType<String>(),
          );
        }
      }
      for (final uri in uris) {
        if (name == 'map_presentation' &&
            relativePath.startsWith('src/map/bloc/') &&
            (uri.startsWith('package:maplibre_gl/') ||
                uri.contains('/src/map/canvas/') ||
                uri.contains('/rendering/'))) {
          errors.add(
            '$name/$relativePath: screen data Bloc must not depend on native map rendering',
          );
        }
        final parsed = Uri.parse(uri);
        if (parsed.scheme == 'dart') {
          if (pure &&
              {'ui', 'io', 'html', 'js_interop'}.contains(parsed.path)) {
            errors.add('$name: platform dependency $uri');
          }
          continue;
        }
        if (parsed.scheme == 'package') {
          final segments = parsed.pathSegments;
          final target = segments.first;
          if (target != name && !dependencies.containsKey(target)) {
            errors.add('$name: undeclared production import $uri');
          }
          if (target != name && segments.skip(1).contains('src')) {
            errors.add('$name: private import $uri');
          }
          if (packages.containsKey(target) &&
              target != name &&
              !(allowed[name]?.contains(target) ?? false)) {
            errors.add('$name: forbidden import $uri');
          }
          if (pure && target != name && target != 'core_common') {
            errors.add('$name: impure domain import $uri');
          }
        } else {
          final resolved = p.normalize(p.join(p.dirname(file.path), uri));
          if (parsed.hasScheme || !p.isWithin(lib.path, resolved)) {
            errors.add('$name: import escapes library: $uri');
          }
        }
      }
      if (ui && !generated) {
        unit.accept(
          UiArchitectureVisitor(
            (message) => errors.add('$name/$relativePath: $message'),
          ),
        );
        for (final uri in uris) {
          final segments = Uri.parse(uri).pathSegments;
          if (uri.startsWith('package:') &&
              (segments.first.endsWith('_domain') ||
                  segments.first.endsWith('_data') ||
                  {
                    'dio',
                    'get_it',
                    'formz',
                    'core_common',
                  }.contains(segments.first) ||
                  segments.contains('di') ||
                  segments.contains('config'))) {
            errors.add(
              '$name/$relativePath: UI must use presentation state and events, not $uri',
            );
          }
        }
      }
      if (name != 'fluent_starter') {
        final featureComposition =
            name.endsWith('_presentation') &&
            (relativePath == 'di/injection.dart' ||
                relativePath ==
                    'src/navigation/${name.replaceFirst('_presentation', '')}_router.dart');
        if (!generated &&
            !featureComposition &&
            uris.any((uri) => uri.startsWith('package:get_it/'))) {
          errors.add(
            '$name: service locator belongs to app composition or feature route/DI composition',
          );
        }
        if (!{
              'map_data',
              'map_presentation',
              'core_network',
              'core_location_data',
            }.contains(name) &&
            uris.any((uri) => uri.startsWith('package:injectable/'))) {
          errors.add(
            '$name: Injectable annotations are not allowed in this layer',
          );
        }
      }
    }
  }
  final visited = <String>{};
  final active = <String>{};
  void visit(String name) {
    if (active.contains(name)) {
      errors.add('Dependency cycle at $name');
      return;
    }
    if (!visited.add(name)) return;
    active.add(name);
    for (final dep in graph[name] ?? <String>{}) {
      visit(dep);
    }
    active.remove(name);
  }

  for (final name in graph.keys) {
    visit(name);
  }
  return errors;
}

bool _isSealedFamily(CompilationUnit unit, int publicTypeCount) {
  final classes = unit.declarations
      .whereType<ClassDeclaration>()
      .where((node) => !node.namePart.typeName.lexeme.startsWith('_'))
      .toList();
  if (classes.length != publicTypeCount) return false;
  final byName = {
    for (final node in classes) node.namePart.typeName.lexeme: node,
  };
  Iterable<String> parents(ClassDeclaration node) => [
    if (node.extendsClause case final clause?) clause.superclass,
    ...?node.implementsClause?.interfaces,
  ].where((type) => type.importPrefix == null).map((type) => type.name.lexeme);
  final roots = classes
      .where(
        (node) =>
            node.sealedKeyword != null &&
            !parents(node).any(byName.containsKey),
      )
      .toList();
  if (roots.length != 1) return false;
  final rootName = roots.single.namePart.typeName.lexeme;
  bool reachesRoot(String name, Set<String> visited) {
    if (name == rootName) return true;
    if (!visited.add(name)) return false;
    final node = byName[name];
    return node != null &&
        parents(node).any((parent) => reachesRoot(parent, {...visited}));
  }

  return byName.keys.every((name) => reachesRoot(name, {}));
}

void main() {
  final errors = checkArchitecture(Directory.current);
  if (errors.isNotEmpty) {
    stderr.writeln(errors.join('\n'));
    exitCode = 1;
  } else {
    stdout.writeln('Architecture boundaries passed.');
  }
}
