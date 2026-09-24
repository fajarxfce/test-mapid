import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';

class HomeOverview extends StatelessWidget {
  const HomeOverview({
    required this.displayName,
    required this.email,
    required this.environment,
    required this.busy,
    required this.onCheckSession,
    required this.onLogout,
    this.message,
    this.onExpireDemoSession,
    super.key,
  });
  final String displayName;
  final String email;
  final String environment;
  final bool busy;
  final String? message;
  final VoidCallback onCheckSession;
  final VoidCallback onLogout;
  final VoidCallback? onExpireDemoSession;

  @override
  Widget build(BuildContext context) => AppPageBody(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(title: 'Welcome, $displayName', subtitle: email),
        const AppGap(),
        Align(
          alignment: Alignment.centerLeft,
          child: AppBadge(
            label: environment,
            semanticsLabel: 'Environment: $environment',
          ),
        ),
        const AppGap(AppSpacing.large),
        const AppCard(
          child: AppBrandHeader(
            title: 'Fluent Starter',
            subtitle: 'Your workspace is ready. Make it your own.',
          ),
        ),
        const AppGap(AppSpacing.large),
        Wrap(
          spacing: AppSpacing.medium,
          runSpacing: AppSpacing.medium,
          children: [
            AppButton(
              label: 'Check session',
              onPressed: busy ? null : onCheckSession,
            ),
            AppButton(
              key: const Key('logout'),
              label: 'Sign out',
              variant: AppButtonVariant.secondary,
              onPressed: busy ? null : onLogout,
            ),
            if (onExpireDemoSession != null)
              AppButton(
                label: 'Expire demo session',
                variant: AppButtonVariant.secondary,
                onPressed: busy ? null : onExpireDemoSession,
              ),
          ],
        ),
        if (message != null) ...[
          const AppGap(),
          AppInfoBar(title: 'Session', message: message!),
        ],
      ],
    ),
  );
}
