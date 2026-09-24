import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Fluent navigation shell. Route state is supplied by the app's AutoTabsRouter.
class AppShellView extends StatelessWidget {
  const AppShellView({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    super.key,
  });
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => NavigationView(
      titleBar: const Padding(
        padding: EdgeInsets.all(16),
        child: AppText('Fluent Starter'),
      ),
      paneBodyBuilder: (_, _) => child,
      pane: NavigationPane(
        displayMode: constraints.maxWidth < AppSpacing.compactBreakpoint
            ? PaneDisplayMode.minimal
            : PaneDisplayMode.expanded,
        selected: selectedIndex,
        onChanged: onDestinationSelected,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const AppText('Overview'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const AppText('Preferences'),
            body: const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  );
}
