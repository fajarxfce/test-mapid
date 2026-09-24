import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {bool dark = false}) => FluentApp(
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  home: ScaffoldPage(content: AppPageBody(child: child)),
);

Finder tooltip(String message) => find.byWidgetPredicate(
  (widget) => widget is Tooltip && widget.message == message,
);

void main() {
  testWidgets(
    'loading button retains its label and blocks mouse and keyboard activation',
    (tester) async {
      var calls = 0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        host(
          AppButton(
            label: 'Save',
            onPressed: () => calls++,
            focusNode: focus,
            autofocus: true,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, 1);
      await tester.pumpWidget(
        host(
          AppButton(
            label: 'Save',
            onPressed: () => calls++,
            focusNode: focus,
            isLoading: true,
          ),
        ),
      );
      await tester.tap(find.text('Save'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 200));
      expect(calls, 1);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(AppProgressRing), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('icon action exposes one accessible label and a tooltip', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      host(
        AppIconButton(
          icon: FluentIcons.refresh,
          tooltip: 'Refresh workspace',
          onPressed: () {},
        ),
      ),
    );
    expect(find.bySemanticsLabel('Refresh workspace'), findsOneWidget);
    expect(tooltip('Refresh workspace'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'validation rebuild preserves editing and exposes its label and error',
    (tester) async {
      final semantics = tester.ensureSemantics();

      String? changed;
      await tester.pumpWidget(
        host(
          AppTextField(label: 'Email', onChanged: (value) => changed = value),
        ),
      );
      await tester.enterText(find.byType(AppTextField), 'alex@');
      expect(changed, 'alex@');
      await tester.pumpWidget(
        host(
          AppTextField(
            label: 'Email',
            onChanged: (value) => changed = value,
            errorText: 'Enter a valid email address.',
            helpText: 'Use your work email.',
          ),
        ),
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'alex@',
      );
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use your work email.'), findsNothing);
      expect(
        tester.getSemantics(find.byType(TextBox)).label,
        contains('Email'),
      );
      expect(
        tester
            .getSemantics(find.text('Enter a valid email address.'))
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'password visibility is controlled and never resets the password',
    (tester) async {
      final controller = TextEditingController(text: 'secure-value');
      addTearDown(controller.dispose);
      bool? requested;
      await tester.pumpWidget(
        host(
          AppPasswordField(
            label: 'Password',
            controller: controller,
            onObscureTextChanged: (obscure) => requested = obscure,
          ),
        ),
      );
      await tester.tap(tooltip('Show password'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(requested, isFalse);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );
      await tester.pumpWidget(
        host(
          AppPasswordField(
            label: 'Password',
            controller: controller,
            obscureText: false,
            onObscureTextChanged: (obscure) => requested = obscure,
          ),
        ),
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
      expect(controller.text, 'secure-value');
      expect(tooltip('Hide password'), findsOneWidget);
    },
  );

  testWidgets(
    'dropdown reports selection and reflects the next external value',
    (tester) async {
      const options = [
        AppSelectOption(value: 1, label: 'First'),
        AppSelectOption(value: 2, label: 'Second'),
        AppSelectOption(value: 3, label: 'Unavailable', enabled: false),
      ];
      int? selected;
      await tester.pumpWidget(
        host(
          AppDropdown<int>(
            label: 'Workspace',
            value: 1,
            options: options,
            onChanged: (value) => selected = value,
          ),
        ),
      );
      await tester.tap(find.byType(ComboBox<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unavailable').last);
      await tester.pump();
      expect(selected, isNull);
      await tester.tap(find.text('Second').last);
      await tester.pumpAndSettle();
      expect(selected, 2);
      expect(tester.widget<ComboBox<int>>(find.byType(ComboBox<int>)).value, 1);
      await tester.pumpWidget(
        host(
          AppDropdown<int>(
            label: 'Workspace',
            value: selected,
            options: options,
            onChanged: (value) => selected = value,
          ),
        ),
      );
      expect(tester.widget<ComboBox<int>>(find.byType(ComboBox<int>)).value, 2);
    },
  );

  testWidgets('checkbox and switch emit changes without owning feature state', (
    tester,
  ) async {
    bool? checked;
    bool? switched;
    await tester.pumpWidget(
      host(
        Column(
          children: [
            AppCheckbox(
              label: 'Remember me',
              value: false,
              onChanged: (value) => checked = value,
            ),
            AppSwitch(
              label: 'Notifications',
              value: false,
              onChanged: (value) => switched = value,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Remember me'));
    await tester.tap(find.text('Notifications'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(checked, isTrue);
    expect(switched, isTrue);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).checked, isFalse);
    expect(
      tester.widget<ToggleSwitch>(find.byType(ToggleSwitch)).checked,
      isFalse,
    );
  });

  testWidgets(
    'radio group supports keyboard selection and skips disabled choices',
    (tester) async {
      int? selected;
      await tester.pumpWidget(
        host(
          AppRadioGroup<int>(
            label: 'Plan',
            value: 1,
            options: const [
              AppSelectOption(value: 1, label: 'Personal'),
              AppSelectOption(value: 2, label: 'Unavailable', enabled: false),
              AppSelectOption(value: 3, label: 'Team'),
            ],
            onChanged: (value) => selected = value,
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(selected, 3);
    },
  );

  testWidgets(
    'search clearing dispatches an intent without mutating the caller controller',
    (tester) async {
      final controller = TextEditingController(text: 'report');
      addTearDown(controller.dispose);
      var clears = 0;
      await tester.pumpWidget(
        host(AppSearchField(controller: controller, onClear: () => clears++)),
      );
      await tester.tap(tooltip('Clear search'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(clears, 1);
      expect(controller.text, 'report');
    },
  );

  testWidgets(
    'progress fractions announce percentages and reject invalid values',
    (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        host(const AppProgressBar(value: 0.5, label: 'Uploading')),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Uploading')).value,
        '50%',
      );
      expect(() => AppProgressRing(value: 2), throwsAssertionError);
      expect(() => AppProgressBar(value: -1), throwsAssertionError);
      semantics.dispose();
    },
  );

  for (final dark in [false, true]) {
    testWidgets('primary button inherits its foreground in dark=$dark', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          AppButton(label: 'Continue', onPressed: () {}),
          dark: dark,
        ),
      );
      final context = tester.element(find.text('Continue'));
      expect(
        tester.widget<Text>(find.text('Continue')).style?.color,
        FluentTheme.of(context).resources.textOnAccentFillColorPrimary,
      );
    });
  }
}
