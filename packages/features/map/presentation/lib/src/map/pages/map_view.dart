import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/widgets/map_canvas.dart';
import 'package:map_presentation/src/map/widgets/map_controls.dart';
import 'package:map_presentation/src/map/widgets/map_location_card.dart';
import 'package:map_presentation/src/map/widgets/place_popup.dart';

class MapView extends StatelessWidget {
  const MapView({this.canvas = const MapCanvas(), super.key});
  final Widget canvas;
  @override
  Widget build(BuildContext context) => BlocBuilder<MapBloc, MapState>(
    builder: (context, state) => ScaffoldPage(
      padding: EdgeInsets.zero,
      content: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
              child: Row(
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF1468D4),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(
                        FluentIcons.map_pin,
                        color: Colors.white,
                        size: 23,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          'MAPID Explorer',
                          variant: AppTextVariant.subtitle,
                        ),
                        AppText(
                          state.layerName,
                          variant: AppTextVariant.caption,
                        ),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: FluentIcons.refresh,
                    tooltip: 'Muat ulang data wisata',
                    onPressed: state.loadingLayer
                        ? null
                        : () => context.read<MapBloc>().add(
                            const MapLayerRequested(),
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  if (state.loadingLayer || !state.styleReady)
                    const AppProgressRing(size: 13, strokeWidth: 2)
                  else
                    const Icon(
                      FluentIcons.location,
                      color: Color(0xFFD0642D),
                      size: 14,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      state.layerCaption,
                      variant: AppTextVariant.caption,
                    ),
                  ),
                  const AppText('GEO MAPID', variant: AppTextVariant.caption),
                ],
              ),
            ),
            if (state.layerError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AppInfoBar(
                  title: 'Data belum dimuat',
                  message: state.layerError,
                  status: AppStatus.warning,
                  action: AppButton(
                    label: 'Coba lagi',
                    onPressed: () =>
                        context.read<MapBloc>().add(const MapLayerRequested()),
                  ),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    Positioned.fill(child: canvas),
                    Positioned(
                      top: 14,
                      right: 12,
                      child: MapControls(enabled: state.styleReady),
                    ),
                    if (state.mapError != null)
                      Positioned(
                        top: 14,
                        left: 12,
                        right: 70,
                        child: AppInfoBar(
                          title: 'Koneksi peta',
                          message: state.mapError,
                          status: AppStatus.warning,
                          action: AppButton(
                            label: 'Muat peta',
                            onPressed: () => context.read<MapBloc>().add(
                              const MapStyleReloadRequested(),
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
                                  onClose: () => context.read<MapBloc>().add(
                                    const MapSelectionCleared(),
                                  ),
                                )
                              : MapLocationCard(state: state),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
