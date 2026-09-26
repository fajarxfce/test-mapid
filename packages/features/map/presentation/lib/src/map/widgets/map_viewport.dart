import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/widgets/map_status_card.dart';
import 'package:map_presentation/src/map/widgets/map_toolbar.dart';
import 'package:map_presentation/src/map/widgets/place_details_popup.dart';

class MapViewport extends StatelessWidget {
  const MapViewport({required this.canvas, super.key});
  final Widget canvas;
  @override
  Widget build(BuildContext context) => BlocBuilder<MapBloc, MapState>(
    buildWhen: (before, after) =>
        before.canvasStatus != after.canvasStatus ||
        before.selected != after.selected,
    builder: (context, state) => LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Positioned.fill(child: canvas),
          Positioned(
            top: 14,
            right: 12,
            child: MapToolbar(enabled: state.mapReady),
          ),
          if (!state.mapReady && state.mapError == null)
            const Positioned(
              top: 14,
              left: 12,
              child: AppProgressRing(size: 22),
            ),
          if (state.mapError != null)
            Positioned(
              top: 14,
              left: 12,
              right: 70,
              child: AppInfoBar(
                title: 'Peta belum siap',
                message: state.mapError,
                status: AppStatus.warning,
                action: AppButton(
                  label: 'Muat peta',
                  onPressed: () => context.read<MapBloc>().add(
                    const MapCanvasRetryRequested(),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 42,
            left: 12,
            right: 12,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight: constraints.maxHeight * .6,
                ),
                child: state.selected != null
                    ? PlaceDetailsPopup(
                        details: state.selected!,
                        onClose: () => context.read<MapBloc>().add(
                          const MapSelectionCleared(),
                        ),
                      )
                    : const MapStatusCard(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
