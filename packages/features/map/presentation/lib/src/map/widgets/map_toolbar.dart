import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';

class MapToolbar extends StatelessWidget {
  const MapToolbar({required this.enabled, super.key});
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
              ? () => context.read<MapBloc>().add(const MapZoomRequested(1))
              : null,
        ),
        AppIconButton(
          icon: FluentIcons.remove,
          tooltip: 'Perkecil peta',
          onPressed: enabled
              ? () => context.read<MapBloc>().add(const MapZoomRequested(-1))
              : null,
        ),
        AppIconButton(
          icon: FluentIcons.city_next,
          tooltip: 'Lihat tempat wisata',
          onPressed: enabled
              ? () => context.read<MapBloc>().add(
                  const MapFocusRequested(MapCameraFocus.places),
                )
              : null,
        ),
      ],
    ),
  );
}
