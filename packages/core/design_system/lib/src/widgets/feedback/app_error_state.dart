import 'package:core_design_system/src/widgets/buttons/app_button.dart';
import 'package:core_design_system/src/widgets/feedback/app_empty_state.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    super.key,
  });
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: AppEmptyState(
      title: title,
      message: message,
      icon: FluentIcons.error_badge,
      action: onRetry == null
          ? null
          : AppButton(label: retryLabel, onPressed: onRetry),
    ),
  );
}
