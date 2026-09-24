import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';

class MapLocationCard extends StatelessWidget {
  const MapLocationCard({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<MapBloc, MapState>(
    builder: (context, state) => AppCard(
      backgroundColor: FluentTheme.of(context)
          .resources
          .solidBackgroundFillColorBase,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(
              'Jogja, dari sudut yang berbeda.',
              variant: AppTextVariant.bodyStrong,
            ),
            const SizedBox(height: 4),
            const AppText(
              'Ketuk titik jingga untuk mengenal tempatnya.',
              variant: AppTextVariant.caption,
            ),
            if (state.locationMessage != null) ...[
              const SizedBox(height: 8),
              AppText(state.locationMessage!, variant: AppTextVariant.caption),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: state.locationLabel,
                icon: const Icon(FluentIcons.location, size: 16),
                isLoading: state.locating,
                loadingLabel: 'Mencari lokasi',
                onPressed: () {
                  context.read<MapCanvasBloc>().add(
                    const MapCanvasFocusRequested(MapCameraFocus.userLocation),
                  );
                  context.read<MapBloc>().add(
                    const MapLocationActionRequested(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
