import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Replaces only the native surface; MapCanvas and the SDK widget still build.
class TestMapPlatformView extends MapLibrePlatform {
  TestMapPlatformView({this.surface = const SizedBox.expand()});
  final Widget surface;
  Map<String, dynamic>? creationParams;

  @override
  Widget buildView(
    Map<String, dynamic> creationParams,
    OnPlatformViewCreatedCallback onPlatformViewCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  ) {
    this.creationParams = creationParams;
    return surface;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
