import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/models/place_details.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';

part 'map_canvas_state.freezed.dart';

@freezed
abstract class MapCanvasState with _$MapCanvasState {
  const MapCanvasState._();
  const factory MapCanvasState({
    @Default(MapScene()) MapScene scene,
    @Default(MapRenderStatus.waitingForMap) MapRenderStatus renderStatus,
    PlaceDetails? selected,
  }) = _MapCanvasState;

  bool get ready => renderStatus == MapRenderStatus.ready;
  String? get errorMessage => switch (renderStatus) {
    MapRenderStatus.styleTimeout =>
      'Basemap belum dapat dimuat. Periksa koneksi internet lalu coba lagi.',
    MapRenderStatus.renderingFailure =>
      'Peta belum dapat diperbarui. Coba muat ulang basemap.',
    _ => null,
  };
}
