import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/check_architecture.dart';

void main() {
  late Directory root;
  setUp(() {
    root = Directory.systemTemp.createTempSync('architecture_');
    File(p.join(root.path, 'pubspec.yaml'))
        .writeAsStringSync('workspace: [common, domain]\n');
    for (final entry in {
      'common': 'core_common',
      'domain': 'map_domain',
    }.entries) {
      Directory(p.join(root.path, entry.key, 'lib'))
          .createSync(recursive: true);
      File(p.join(root.path, entry.key, 'pubspec.yaml')).writeAsStringSync(
        'name: ${entry.value}\ndependencies: ${entry.key == 'domain' ? '{core_common: any}' : '{}'}\n',
      );
    }
  });
  tearDown(() => root.deleteSync(recursive: true));
  test('accepts allowed domain dependency', () {
    File(p.join(root.path, 'domain/lib/domain.dart'))
        .writeAsStringSync("import 'package:core_common/core_common.dart';");
    expect(checkArchitecture(root), isEmpty);
  });
  test('permits pure equality utilities but still rejects transport dependencies', () {
    final spec = File(p.join(root.path, 'domain/pubspec.yaml'));
    final source = File(p.join(root.path, 'domain/lib/domain.dart'));
    for (final dependency in ['collection', 'equatable']) {
      spec.writeAsStringSync(
        'name: map_domain\ndependencies: {core_common: any, $dependency: any}\n',
      );
      source.writeAsStringSync(
        "import 'package:$dependency/$dependency.dart';",
      );
      expect(checkArchitecture(root), isEmpty);
    }
    spec.writeAsStringSync(
      'name: map_domain\ndependencies: {core_common: any, dio: any}\n',
    );
    source.writeAsStringSync("import 'package:dio/dio.dart';");
    expect(
      checkArchitecture(root),
      contains(contains('approved pure Dart packages')),
    );
    expect(checkArchitecture(root), contains(contains('impure domain import')));
  });
  test('shared location cannot depend on a feature', () {
    File(p.join(root.path, 'pubspec.yaml'))
        .writeAsStringSync('workspace: [common, domain, location]\n');
    Directory(p.join(root.path, 'location/lib')).createSync(recursive: true);
    File(p.join(root.path, 'location/pubspec.yaml')).writeAsStringSync(
      'name: core_location_data\ndependencies: {core_common: any, map_domain: any}\n',
    );
    expect(
      checkArchitecture(root),
      contains(contains('forbidden dependency map_domain')),
    );
  });
  test('screen data Bloc cannot import a native map SDK', () {
    File(p.join(root.path, 'domain/pubspec.yaml')).writeAsStringSync(
      'name: map_presentation\ndependencies: {core_common: any, maplibre_gl: any}\n',
    );
    final file = File(
      p.join(root.path, 'domain/lib/src/map/bloc/map_bloc.dart'),
    );
    file.parent.createSync(recursive: true);
    file.writeAsStringSync("import 'package:maplibre_gl/maplibre_gl.dart';");
    expect(
      checkArchitecture(root),
      contains(
        contains('screen data Bloc must not depend on native map rendering'),
      ),
    );
  });
  test('Blocs cannot depend on sibling Blocs', () {
    File(p.join(root.path, 'domain/pubspec.yaml')).writeAsStringSync(
      'name: map_presentation\ndependencies: {core_common: any}\n',
    );
    final file = File(
      p.join(root.path, 'domain/lib/src/map/bloc/map_bloc.dart'),
    );
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      'class MapBloc extends Bloc<Event, State> { MapBloc(this.other); final OtherBloc other; }',
    );
    expect(
      checkArchitecture(root),
      contains(contains('Blocs must not depend on another Bloc')),
    );
  });
  test('canvas Bloc depends on the renderer contract, not native adapters', () {
    File(p.join(root.path, 'domain/pubspec.yaml')).writeAsStringSync(
      'name: map_presentation\ndependencies: {core_common: any, maplibre_gl: any, synchronized: any}\n',
    );
    final file = File(
      p.join(root.path, 'domain/lib/src/map/canvas/bloc/map_canvas_bloc.dart'),
    );
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      "import 'package:map_presentation/src/map/canvas/rendering/map_renderer.dart';",
    );
    expect(checkArchitecture(root), isEmpty);
    for (final uri in [
      'package:maplibre_gl/maplibre_gl.dart',
      'package:synchronized/synchronized.dart',
      'package:map_presentation/src/map/canvas/rendering/map_libre_render_session.dart',
    ]) {
      file.writeAsStringSync("import '$uri';");
      expect(
        checkArchitecture(root),
        contains(contains('canvas Bloc must use the renderer contract')),
      );
    }
  });
  test(
    'canvas events and renderer contracts cannot expose SDK dependencies',
    () {
      File(p.join(root.path, 'domain/pubspec.yaml')).writeAsStringSync(
        'name: map_presentation\ndependencies: {core_common: any, maplibre_gl: any}\n',
      );
      for (final path in [
        'src/map/canvas/bloc/map_canvas_event.dart',
        'src/map/canvas/rendering/map_renderer.dart',
      ]) {
        final file = File(p.join(root.path, 'domain/lib', path));
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(
          "import 'package:maplibre_gl/maplibre_gl.dart';",
        );
        expect(
          checkArchitecture(root),
          contains(contains('canvas Bloc must use the renderer contract')),
        );
        file.deleteSync();
      }
    },
  );

  test('datasource and DTO boundaries reject domain models and Result wrappers', () {
    File(p.join(root.path, 'domain/pubspec.yaml')).writeAsStringSync(
      'name: map_data\ndependencies: {core_common: any, map_domain: any}\n',
    );
    for (final path in [
      'src/datasources/source.dart',
      'src/dto/fix_dto.dart',
    ]) {
      final file = File(p.join(root.path, 'domain/lib', path));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync("import 'package:map_domain/map_domain.dart';");
      expect(
        checkArchitecture(root),
        contains(contains('datasource/DTO must not depend on domain')),
      );
      file.writeAsStringSync(
        "import 'package:core_common/core_common.dart'; Result<double>? fix;",
      );
      expect(
        checkArchitecture(root),
        contains(contains('Result/Failure belongs to the repository')),
      );
      file.writeAsStringSync(
        'class FixDto { const FixDto(this.latitude); final double latitude; }',
      );
      expect(checkArchitecture(root), isEmpty);
      file.deleteSync();
    }
  });

  test('presentation accepts feature sources under src and DI beside src', () {
    File(p.join(root.path, 'domain/pubspec.yaml')).writeAsStringSync(
      'name: map_presentation\ndependencies: {core_common: any}\n',
    );
    for (final entry in {
      'map_presentation.dart': "export 'src/map/bloc/map_event.dart';",
      'di/injection.dart': 'void configureMapPresentationPackage() {}',
      'src/map/bloc/map_event.dart': 'sealed class MapEvent {}\nfinal class MapSubmitted extends MapEvent {}',
    }.entries) {
      final file = File(p.join(root.path, 'domain/lib', entry.key));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
    expect(checkArchitecture(root), isEmpty);
  });
  test('presentation rejects feature sources outside src', () {
    File(p.join(root.path, 'domain/pubspec.yaml')).writeAsStringSync(
      'name: map_presentation\ndependencies: {core_common: any}\n',
    );
    final file = File(p.join(root.path, 'domain/lib/map/bloc/map_bloc.dart'));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('class MapBloc {}');
    expect(
      checkArchitecture(root),
      contains(contains('presentation features belong in lib/src')),
    );
  });
  test('rejects framework and conditional platform imports', () {
    File(p.join(root.path, 'domain/lib/domain.dart')).writeAsStringSync(
      "import 'package:flutter/widgets.dart';\nimport 'stub.dart' if (dart.library.io) 'dart:io';",
    );
    expect(checkArchitecture(root), contains(contains('impure domain')));
    expect(checkArchitecture(root), contains(contains('platform dependency')));
  });
  test('rejects private exports and relative escapes', () {
    File(p.join(root.path, 'domain/lib/domain.dart')).writeAsStringSync(
      "export 'package:core_common/src/private.dart';\nexport '../../common/lib/common.dart';",
    );
    expect(checkArchitecture(root), contains(contains('private import')));
    expect(checkArchitecture(root), contains(contains('escapes library')));
  });
  test('rejects forbidden dependency and cycles', () {
    File(
      p.join(root.path, 'common/pubspec.yaml'),
    ).writeAsStringSync('name: core_common\ndependencies: {map_domain: any}\n');
    expect(checkArchitecture(root), contains(contains('forbidden dependency')));
    expect(checkArchitecture(root), contains(contains('cycle')));
  });
  test('rejects implementations and imports in a package barrel', () {
    File(p.join(root.path, 'domain/lib/map_domain.dart')).writeAsStringSync(
      "import 'package:core_common/core_common.dart';\nclass User {}",
    );
    expect(checkArchitecture(root), contains(contains('only exports')));
  });
  test('rejects unrelated public types in one implementation file', () {
    File(p.join(root.path, 'domain/lib/models.dart')).writeAsStringSync(
      'class User {}\nabstract interface class MapRepository {}',
    );
    expect(checkArchitecture(root), contains(contains('split public types')));
  });
  test('accepts a sealed event family in one source file', () {
    File(p.join(root.path, 'domain/lib/map_event.dart')).writeAsStringSync('''
sealed class MapEvent {}
final class MapSubmitted extends MapEvent {}
final class MapCancelled implements MapEvent {}
''');
    expect(checkArchitecture(root), isEmpty);
  });
  test('accepts one sealed event family with a nested scene family', () {
    File(p.join(root.path, 'domain/lib/map_event.dart')).writeAsStringSync('''
sealed class MapEvent {}
final class LayerRequested extends MapEvent {}
sealed class SceneEvent extends MapEvent {}
final class StyleLoaded extends SceneEvent {}
final class MapTapped extends SceneEvent {}
''');
    expect(checkArchitecture(root), isEmpty);
  });
  test('sealed family exception still rejects unrelated public types', () {
    for (final unrelated in [
      'class MapRepository {}',
      'enum MapStatus { idle }',
      'sealed class SessionEvent {}',
      'final class OtherSubmitted extends other.MapEvent {}',
    ]) {
      File(p.join(root.path, 'domain/lib/map_event.dart')).writeAsStringSync('''
sealed class MapEvent {}
final class MapSubmitted extends MapEvent {}
$unrelated
''');
      expect(
        checkArchitecture(root),
        contains(contains('split public types')),
        reason: unrelated,
      );
    }
  });
  test('accepts export barrels, private companions and generated types', () {
    File(p.join(root.path, 'domain/lib/map_domain.dart'))
        .writeAsStringSync("export 'view.dart';");
    File(p.join(root.path, 'domain/lib/view.dart'))
        .writeAsStringSync('class View {}\nclass _ViewState {}');
    File(p.join(root.path, 'domain/lib/view.g.dart'))
        .writeAsStringSync('class GeneratedView {}\nclass GeneratedState {}');
    expect(checkArchitecture(root), isEmpty);
  });
  test('rejects Cubit implementations', () {
    File(p.join(root.path, 'domain/lib/state.dart'))
        .writeAsStringSync('class SessionCubit extends Cubit<int> {}');
    expect(
      checkArchitecture(root),
      contains(contains('use Bloc with explicit events')),
    );
  });
  for (final source in [
    'class Page extends ui.StatefulWidget {}',
    'class PageState extends ui.State<Page> {}',
    'typedef LegacyState<T> = ui.State<T>;',
    'typedef LegacyCubit = bloc.Cubit<int>;',
    'mixin Legacy on ChangeNotifier {}',
    'final count = ValueNotifier(0);',
    'final count = new ui.ValueNotifier<int>(0);',
    'final factory = ui.ChangeNotifier.new;',
    'Widget view() => ui.ValueListenableBuilder(valueListenable: count, builder: render);',
    'Widget view() => ListenableBuilder(listenable: count, builder: render);',
    'Widget view() => StatefulBuilder(builder: render);',
    'void update() { setState(() {}); }',
    'final update = state.setState;',
  ]) {
    test('rejects legacy state outside UI directories: $source', () {
      File(p.join(root.path, 'domain/lib/example.dart'))
          .writeAsStringSync(source);
      expect(
        checkArchitecture(root),
        contains(contains('use Bloc with explicit events')),
      );
    });
  }
  test('accepts Bloc, immutable state, comments and literal UI copy', () {
    File(p.join(root.path, 'domain/lib/example.dart')).writeAsStringSync('''
// Replace ChangeNotifier and setState with events.
class ExampleBloc extends Bloc<Event, ExampleState> {}
const explanation = 'Cubit, ValueNotifier and StatefulWidget';
''');
    expect(checkArchitecture(root), isEmpty);
  });
  test('rejects service locator access outside app composition', () {
    File(p.join(root.path, 'domain/lib/locator.dart'))
        .writeAsStringSync("import 'package:get_it/get_it.dart';");
    expect(
      checkArchitecture(root),
      contains(contains('service locator belongs to app composition')),
    );
  });
  test('keeps Injectable out of domain', () {
    File(p.join(root.path, 'domain/lib/di.dart'))
        .writeAsStringSync("import 'package:injectable/injectable.dart';");
    expect(
      checkArchitecture(root),
      contains(contains('Injectable annotations are not allowed')),
    );
  });
  test(
    'feature DI and router configuration can resolve route-scoped Blocs',
    () {
      File(p.join(root.path, 'domain/pubspec.yaml')).writeAsStringSync(
        'name: map_presentation\ndependencies: {get_it: any}\n',
      );
      for (final path in [
        'di/injection.dart',
        'src/navigation/map_router.dart',
      ]) {
        final file = File(p.join(root.path, 'domain/lib', path));
        file.parent.createSync(recursive: true);
        file.writeAsStringSync("import 'package:get_it/get_it.dart';");
      }
      expect(checkArchitecture(root), isEmpty);
    },
  );
  for (final path in [
    'src/map/bloc/map_bloc.dart',
    'src/map/pages/map_page.dart',
    'src/navigation/helpers.dart',
  ]) {
    test('feature locator access is rejected in $path', () {
      File(p.join(root.path, 'domain/pubspec.yaml')).writeAsStringSync(
        'name: map_presentation\ndependencies: {get_it: any}\n',
      );
      final file = File(p.join(root.path, 'domain/lib', path));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync("import 'package:get_it/get_it.dart';");
      expect(
        checkArchitecture(root),
        contains(contains('service locator belongs to')),
      );
    });
  }
  void writeView(String source) {
    final file = File(p.join(root.path, 'domain/lib/map/pages/map_view.dart'));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
  }

  test('UI checks cover feature folders and shared or app widgets', () {
    for (final path in [
      'map/pages/map_view.dart',
      'map/widgets/map_form.dart',
      'src/views/example_view.dart',
      'src/widgets/example_widget.dart',
      'routing/pages/example_page.dart',
    ]) {
      final file = File(p.join(root.path, 'domain/lib', path));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        'class View { void submit() => repository.map(); }',
      );
      expect(
        checkArchitecture(root),
        contains('map_domain/$path: UI must not declare logic/helper methods'),
        reason: path,
      );
      file.deleteSync();
    }
  });

  test('UI rejects async handlers and helper methods', () {
    writeView(
      'class View { void check() async { await repository.restore(); } Widget build() => Button(onPressed: () async { await check(); }); }',
    );
    expect(
      checkArchitecture(root),
      contains(contains('UI must not declare logic/helper methods')),
    );
    expect(
      checkArchitecture(root),
      contains(contains('UI must not await operations')),
    );
    expect(
      checkArchitecture(root),
      contains(contains('UI must not perform asynchronous work')),
    );
  });
  test('UI rejects imperative decisions, mutation and subscriptions', () {
    writeView(
      'class View { Widget build() { if (user != null) { route = home; } stream.listen(update); return Page(); } }',
    );
    expect(
      checkArchitecture(root),
      contains(contains('UI must not make imperative decisions')),
    );
    expect(
      checkArchitecture(root),
      contains(contains('UI must not mutate application state')),
    );
    expect(
      checkArchitecture(root),
      contains(contains('UI must not manage asynchronous effects')),
    );
  });
  test('UI cannot import use cases, data, storage or service locators', () {
    writeView(
      "import 'package:map_domain/map_domain.dart'; import 'package:get_it/get_it.dart';",
    );
    expect(
      checkArchitecture(root),
      contains(contains('UI must use presentation state and events')),
    );
  });
  test('UI accepts rendering state and dispatching events', () {
    writeView(
      'class View { Widget build() => Column(children: [if (state.busy) Progress(), Button(onPressed: () => bloc.add(Submitted()))]); }',
    );
    expect(checkArchitecture(root), isEmpty);
  });
}
