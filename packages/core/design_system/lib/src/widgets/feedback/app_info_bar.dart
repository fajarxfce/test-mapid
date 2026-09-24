import 'package:core_design_system/src/tokens/app_status.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppInfoBar extends StatelessWidget {
  const AppInfoBar({
    required this.title,
    this.message,
    this.status = AppStatus.info,
    this.action,
    this.onClose,
    this.selectable = false,
    super.key,
  });
  final String title;
  final String? message;
  final AppStatus status;
  final Widget? action;
  final VoidCallback? onClose;
  final bool selectable;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: InfoBar(
      title: AppText(title),
      content: message == null
          ? null
          : AppText(message!, selectable: selectable),
      action: action,
      onClose: onClose,
      isLong: true,
      severity: switch (status) {
        AppStatus.neutral || AppStatus.info => InfoBarSeverity.info,
        AppStatus.success => InfoBarSeverity.success,
        AppStatus.warning => InfoBarSeverity.warning,
        AppStatus.error => InfoBarSeverity.error,
      },
    ),
  );
}
