import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final dark in [false, true]) {
    for (final width in [320.0, 1280.0]) {
      testWidgets(
        'component catalog fits width=$width, dark=$dark at 200% text',
        (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final components = <Widget>[
            for (final variant in AppTextVariant.values)
              AppText('Design system', variant: variant),
            const AppText('Selectable content', selectable: true),
            AppPageHeader(
              title: 'Workspace preferences',
              subtitle: 'Adjust settings for your workspace.',
              actions: [AppButton(label: 'Save all changes', onPressed: () {})],
            ),
            const AppBrandHeader(
              title: 'Fluent Starter',
              subtitle: 'Made for your workspace.',
            ),
            for (final variant in AppButtonVariant.values)
              AppButton(
                label: 'Continue to your workspace',
                variant: variant,
                onPressed: () {},
              ),
            AppButton(
              label: 'Saving your changes',
              isLoading: true,
              onPressed: () {},
            ),
            AppIconButton(
              icon: FluentIcons.add,
              tooltip: 'Add item',
              onPressed: () {},
            ),
            const AppTextField(
              label: 'Email address',
              placeholder: 'you@example.com',
              errorText: 'Enter a valid email address before continuing.',
            ),
            const AppTextField(
              label: 'Disabled field',
              enabled: false,
              placeholder: 'Unavailable',
            ),
            AppPasswordField(label: 'Password', onObscureTextChanged: (_) {}),
            const AppTextArea(
              label: 'Description',
              placeholder: 'Tell us more',
            ),
            AppSearchField(label: 'Find a file', onClear: () {}),
            AppDropdown<int>(
              label: 'Workspace',
              value: 1,
              options: const [
                AppSelectOption(value: 1, label: 'Personal workspace'),
              ],
              onChanged: (_) {},
            ),
            AppCheckbox(
              label: 'Remember this device for future visits',
              value: true,
              onChanged: (_) {},
            ),
            AppSwitch(
              label: 'Receive desktop notifications',
              value: false,
              onChanged: (_) {},
            ),
            AppRadioGroup<int>(
              label: 'Plan',
              value: 1,
              onChanged: (_) {},
              options: const [
                AppSelectOption(value: 1, label: 'Personal workspace'),
              ],
            ),
            AppSlider(label: 'Volume', value: 0.5, onChanged: (_) {}),
            AppDatePicker(
              label: 'Start date',
              value: DateTime(2026, 9, 24),
              onChanged: (_) {},
            ),
            AppTimePicker(
              label: 'Reminder',
              value: DateTime(2026, 9, 24, 14, 30),
              onChanged: (_) {},
            ),
            const AppCard(child: AppText('A reusable content surface.')),
            const AppSection(
              title: 'Account',
              description: 'Your public profile',
              child: AppSkeleton(),
            ),
            for (final status in AppStatus.values)
              AppBadge(
                label: 'Workspace status: ${status.name}',
                status: status,
              ),
            const Center(
              child: AppAvatar(label: 'Alex Morgan', initials: 'AM'),
            ),
            AppListTile(
              title: 'Account settings',
              subtitle: 'Manage your profile and sign-in options.',
              leading: const Icon(FluentIcons.settings),
              onPressed: () {},
            ),
            const AppExpander(
              title: 'Advanced options',
              initiallyExpanded: true,
              child: AppText('Additional settings appear here.'),
            ),
            const AppTooltip(
              message: 'Additional context',
              child: AppText('Hover for details'),
            ),
            for (final status in AppStatus.values)
              AppInfoBar(
                title: 'Workspace update',
                message: 'Your changes have been processed.',
                status: status,
                action: AppButton(label: 'View details', onPressed: () {}),
              ),
            const Center(child: AppProgressRing(value: 0.5)),
            const AppProgressBar(value: 0.5),
            const AppEmptyState(
              title: 'No documents yet',
              message: 'Create a document to get started.',
            ),
            AppErrorState(
              title: 'Unable to load documents',
              message: 'Please try again.',
              onRetry: () {},
            ),
            const AppLoadingState(label: 'Loading documents', value: 0.5),
            const AppSkeleton(),
            const AppDivider(),
            const AppGap(),
          ];
          for (final component in components) {
            await tester.pumpWidget(
              FluentApp(
                theme: dark ? AppTheme.dark() : AppTheme.light(),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: Size(width, 900),
                    textScaler: const TextScaler.linear(2),
                  ),
                  child: ScaffoldPage(content: AppPageBody(child: component)),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 250));
            expect(
              tester.takeException(),
              isNull,
              reason: '${component.runtimeType} at $width',
            );
          }
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets(
    'dialog actions wrap on small screens and leave dismissal to the caller',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var confirmations = 0;
      await tester.pumpWidget(
        FluentApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 800),
              textScaler: TextScaler.linear(2),
            ),
            child: AppDialog(
              title: 'Delete this document?',
              actions: [
                AppButton(
                  label: 'Keep editing',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Delete document',
                  onPressed: () => confirmations++,
                ),
              ],
              child: const AppText('This action is permanent.'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Delete document'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(confirmations, 1);
      expect(find.byType(AppDialog), findsOneWidget);
    },
  );
}
