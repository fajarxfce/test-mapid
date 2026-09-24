import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_state.dart';
import 'package:map_presentation/src/map/widgets/map_controls.dart';
import 'package:map_presentation/src/map/widgets/map_location_card.dart';
import 'package:map_presentation/src/map/widgets/place_popup.dart';

class MapViewport extends StatelessWidget {
  const MapViewport({required this.canvas, super.key});
  final Widget canvas;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MapCanvasBloc, MapCanvasState>(
        buildWhen: (before, after) =>
            before.renderStatus != after.renderStatus ||
            before.selected != after.selected,
        builder: (context, state) => LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(child: canvas),
              Positioned(
                top: 14,
                right: 12,
                child: MapControls(enabled: state.ready),
              ),
              if (!state.ready && state.errorMessage == null)
                const Positioned(
                  top: 14,
                  left: 12,
                  child: AppProgressRing(size: 22),
                ),
              if (state.errorMessage != null)
                Positioned(
                  top: 14,
                  left: 12,
                  right: 70,
                  child: AppInfoBar(
                    title: 'Koneksi peta',
                    message: state.errorMessage,
                    status: AppStatus.warning,
                    action: AppButton(
                      label: 'Muat peta',
                      onPressed: () => context.read<MapCanvasBloc>().add(
                        const MapCanvasStyleReloadRequested(),
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
                        ? PlacePopup(
                            details: state.selected!,
                            onClose: () => context.read<MapCanvasBloc>().add(
                              const MapCanvasSelectionCleared(),
                            ),
                          )
                        : const MapLocationCard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
