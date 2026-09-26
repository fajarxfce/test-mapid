import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/models/place_details.dart';

import 'support/map_fixtures.dart';

void main() {
  test('independent equivalent popup values do not change page state', () {
    final first = PlaceDetails.fromPlace(samplePlace);
    final second = PlaceDetails.fromPlace(copySamplePlace());
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(MapState(selected: first), MapState(selected: second));
    expect(
      first,
      isNot(PlaceDetails.fromPlace(copySamplePlace(name: 'Renamed'))),
    );
  });
}
