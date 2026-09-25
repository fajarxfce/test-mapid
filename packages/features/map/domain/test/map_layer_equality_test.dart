import 'package:core_common/core_common.dart';
import 'package:map_domain/map_domain.dart';
import 'package:test/test.dart';

MapPlace place({String id = '1', String address = 'First address'}) => MapPlace(
  id: id,
  name: 'Museum',
  address: address,
  city: 'Yogyakarta',
  district: 'Gondokusuman',
  period: '2026',
  point: GeoPoint(latitude: -7.8, longitude: 110.36),
);

void main() {
  test('refreshing identical content preserves layer equality and hash', () {
    final first = MapLayer(name: 'Tourism', places: [place()]);
    final refreshed = MapLayer(name: 'Tourism', places: [place()]);
    expect(identical(first.places.single, refreshed.places.single), isFalse);
    expect(first, refreshed);
    expect(first.hashCode, refreshed.hashCode);
  });

  test('stable IDs do not hide changed attributes or place ordering', () {
    final first = MapLayer(
      name: 'Tourism',
      places: [
        place(),
        place(id: '2'),
      ],
    );
    expect(
      MapLayer(
        name: 'Tourism',
        places: [
          place(address: 'New address'),
          place(id: '2'),
        ],
      ),
      isNot(first),
    );
    expect(
      MapLayer(
        name: 'Tourism',
        places: [
          place(id: '2'),
          place(),
        ],
      ),
      isNot(first),
    );
    expect(MapLayer(name: 'Renamed', places: first.places), isNot(first));
  });

  test('caller mutation cannot change a layer value or its hash', () {
    final input = [place()];
    final layer = MapLayer(name: 'Tourism', places: input);
    final hash = layer.hashCode;
    input.add(place(id: '2'));
    expect(layer.places, hasLength(1));
    expect(layer.hashCode, hash);
    expect(() => layer.places.clear(), throwsUnsupportedError);
  });
}
