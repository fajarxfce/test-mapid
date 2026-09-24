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
        (
          before.layerName,
          before.layerCaption,
          before.loadingLayer,
          before.layerError,
        ) !=
        (
          after.layerName,
          after.layerCaption,
          after.loadingLayer,
          after.layerError,
        ),
    builder: (context, state) => Column(
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
                    AppText(state.layerName, variant: AppTextVariant.caption),
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
              if (state.loadingLayer)
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
      ],
    ),
  );
}
