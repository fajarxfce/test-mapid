import 'package:core_location_data/src/datasources/compass_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: CompassDataSource)
final class FlutterCompassDataSource implements CompassDataSource {
  const FlutterCompassDataSource();

  @override
  Stream<double?> watch() => Rx.defer(() {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return Stream.value(null);
    }
    return (FlutterCompass.events ?? const Stream<CompassEvent>.empty())
        .map(
          (event) =>
              event.heading != null &&
                  event.heading!.isFinite &&
                  event.accuracy != null &&
                  event.accuracy! >= 0
              ? (event.heading!.roundToDouble() % 360)
              : null,
        )
        .throttleTime(const Duration(milliseconds: 100), trailing: true)
        .startWith(null)
        .distinct();
  });
}
