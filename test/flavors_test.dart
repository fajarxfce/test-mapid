import 'dart:io';

import 'package:test/test.dart';

void main() {
  for (final platform in ['ios', 'macos']) {
    for (final flavor in ['dev', 'staging', 'prod']) {
      test('$platform $flavor can build and prepare Flutter frameworks', () {
        final scheme = File(
          'apps/fluent_starter/$platform/Runner.xcodeproj/xcshareddata/xcschemes/$flavor.xcscheme',
        ).readAsStringSync();
        expect(scheme, contains('<BuildActionEntries>'));
        expect(scheme, contains('buildForRunning = "YES"'));
        expect(scheme, contains('buildForArchiving = "YES"'));
        expect(scheme, contains('<PreActions>'));
        expect(scheme, contains('prepare'));
        for (final mode in ['Debug', 'Profile', 'Release']) {
          expect(scheme, contains('buildConfiguration = "$mode-$flavor"'));
        }
      });
    }
  }
}
