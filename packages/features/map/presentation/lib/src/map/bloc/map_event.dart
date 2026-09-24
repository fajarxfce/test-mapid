sealed class MapEvent {
  const MapEvent();
}

final class MapLayerRequested extends MapEvent {
  const MapLayerRequested();
}

final class MapLocationRequested extends MapEvent {
  const MapLocationRequested();
}

final class MapLocationActionRequested extends MapEvent {
  const MapLocationActionRequested();
}
