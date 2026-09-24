import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/widgets/feedback/app_progress_ring.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({this.label = 'Loading', this.value, super.key});
  final String label;
  final double? value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.large),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: AppProgressRing(value: value)),
        const SizedBox(height: AppSpacing.medium),
        Semantics(liveRegion: true, child: AppText(label)),
      ],
    ),
  );
}
