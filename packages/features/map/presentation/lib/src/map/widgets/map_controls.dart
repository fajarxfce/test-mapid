import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';

class MapControls extends StatelessWidget {
  const MapControls({required this.enabled, super.key});
  final bool enabled;
  @override
  Widget build(BuildContext context) => AppCard(
    backgroundColor: FluentTheme.of(context)
        .resources
        .solidBackgroundFillColorBase,
    padding: const EdgeInsets.all(4),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(
          icon: FluentIcons.add,
          tooltip: 'Perbesar peta',
          onPressed: enabled
              ? () => context.read<MapCanvasBloc>().add(
                  const MapCanvasZoomRequested(1),
                )
              : null,
        ),
        AppIconButton(
          icon: FluentIcons.remove,
          tooltip: 'Perkecil peta',
          onPressed: enabled
              ? () => context.read<MapCanvasBloc>().add(
                  const MapCanvasZoomRequested(-1),
                )
              : null,
        ),
        AppIconButton(
          icon: FluentIcons.map_layers,
          tooltip: 'Lihat semua tempat',
          onPressed: enabled
              ? () => context.read<MapCanvasBloc>().add(
                  const MapCanvasFocusRequested(MapCameraFocus.places),
                )
              : null,
        ),
      ],
    ),
  );
}
