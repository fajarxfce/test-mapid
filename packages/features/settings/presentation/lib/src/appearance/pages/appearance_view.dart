import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_presentation/src/appearance/bloc/appearance_bloc.dart';
import 'package:settings_presentation/src/appearance/bloc/appearance_event.dart';
import 'package:settings_presentation/src/appearance/bloc/appearance_state.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppearanceBloc, AppearanceState>(
        builder: (context, state) => AppPageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppPageHeader(title: 'Preferences'),
              const AppGap(AppSpacing.large),
              AppDropdown<ThemeMode>(
                key: const Key('appearance_theme'),
                label: 'Appearance',
                value: state.mode,
                options: const [
                  AppSelectOption(
                    value: ThemeMode.system,
                    label: 'Use system setting',
                  ),
                  AppSelectOption(value: ThemeMode.light, label: 'Light'),
                  AppSelectOption(value: ThemeMode.dark, label: 'Dark'),
                ],
                onChanged: (mode) => context.read<AppearanceBloc>().add(
                  AppearanceThemeSelected(mode),
                ),
              ),
              if (state.error != null) ...[
                const AppGap(),
                AppInfoBar(
                  title: 'Appearance',
                  message: state.error!,
                  status: AppStatus.warning,
                ),
              ],
            ],
          ),
        ),
      );
}
