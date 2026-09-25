import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:test/test.dart';

LocationFix fix({
  double latitude = -7.8,
  double accuracy = 10,
  int second = 0,
  double heading = 90,
  LocationBearingSource source = LocationBearingSource.compass,
}) => LocationFix(
  point: GeoPoint(latitude: latitude, longitude: 110.36),
  accuracyMeters: accuracy,
  timestamp: DateTime.utc(2026, 1, 1, 0, 0, second),
  bearing: LocationBearing(degrees: heading, source: source),
);

void main() {
  test(
    'independent sensor fixes compare by value, including nested values',
    () {
      final first = fix();
      final duplicate = fix();
      expect(identical(first, duplicate), isFalse);
      expect(identical(first.point, duplicate.point), isFalse);
      expect(identical(first.bearing, duplicate.bearing), isFalse);
      expect(first, duplicate);
      expect(first.hashCode, duplicate.hashCode);
      expect({first, duplicate}, hasLength(1));
    },
  );

  test('new observations, accuracy and bearing source are not discarded', () {
    expect({
      fix(),
      fix(),
      fix(latitude: -7.81),
      fix(accuracy: 5),
      fix(second: 1),
      fix(heading: 91),
      fix(source: LocationBearingSource.movement),
    }, hasLength(6));
  });
}
