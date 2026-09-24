import 'package:fluent_ui/fluent_ui.dart';

class AppTooltip extends StatelessWidget {
  const AppTooltip({required this.message, required this.child, super.key});
  final String message;
  final Widget child;
  @override
  Widget build(BuildContext context) => Tooltip(message: message, child: child);
}
