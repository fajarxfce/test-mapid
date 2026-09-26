import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';

class MapStatusCard extends StatelessWidget {
  const MapStatusCard({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<MapBloc, MapState>(
    buildWhen: (before, after) =>
        (before.locationMessage, before.locationLabel, before.locating) !=
        (after.locationMessage, after.locationLabel, after.locating),
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
            if (state.locationMessage != null) ...[
              AppText(state.locationMessage!, variant: AppTextVariant.caption),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: state.locationLabel,
                icon: const Icon(FluentIcons.location, size: 16),
                isLoading: state.locating,
                loadingLabel: 'Mencari lokasi',
                onPressed: () => context.read<MapBloc>().add(
                  const MapLocationActionRequested(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
