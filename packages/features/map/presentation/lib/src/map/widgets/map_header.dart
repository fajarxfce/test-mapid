import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';

class MapHeader extends StatelessWidget {
  const MapHeader({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<MapBloc, MapState>(
    buildWhen: (before, after) =>
        (before.loadingLayer, before.layerError) !=
        (after.loadingLayer, after.layerError),
    builder: (context, state) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
          child: Row(
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF1468D4),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    FluentIcons.map_pin,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: AppText(
                  'MAPID Explorer',
                  variant: AppTextVariant.subtitle,
                ),
              ),
              if (state.loadingLayer)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: AppProgressRing(size: 18, strokeWidth: 2),
                )
              else
                AppIconButton(
                  icon: FluentIcons.refresh,
                  tooltip: 'Muat ulang data wisata',
                  onPressed: () =>
                      context.read<MapBloc>().add(const MapLayerRequested()),
                ),
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
      ],
    ),
  );
}
