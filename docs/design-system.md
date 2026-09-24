# App components

`core_design_system` provides **35 reusable widgets** backed by Fluent UI. Import
`package:core_design_system/core_design_system.dart`; each component has its own
file under `lib/src/widgets`, grouped by responsibility.

| Group | Components | Main options |
| --- | --- | --- |
| Typography | `AppText` | Caption, body, strong body, subtitle, title, large title, display; selectable text; alignment and overflow |
| Actions | `AppButton`, `AppIconButton` | Primary, secondary, outlined and link variants; sizes; icons; loading; keyboard focus; tooltips |
| Text inputs | `AppTextField`, `AppPasswordField`, `AppTextArea`, `AppSearchField`, `AppField` | Labels, help/errors, autofill, input formatting, keyboard actions, controllers and focus nodes |
| Selection | `AppDropdown<T>`, `AppCheckbox`, `AppSwitch`, `AppRadioGroup<T>`, `AppSlider` | Externally supplied values/callbacks, typed options, disabled choices, keyboard interaction |
| Pickers | `AppDatePicker`, `AppTimePicker` | Selected values, date bounds, locale, hour format and minute increments |
| Layout | `AppPageBody`, `AppPageHeader`, `AppSection`, `AppCard`, `AppDivider`, `AppGap` | Responsive page gutters, bounded content width, scrolling, headers, sections and spacing |
| Display | `AppAvatar`, `AppBadge`, `AppListTile`, `AppBrandHeader`, `AppExpander`, `AppTooltip` | Avatar fallback, semantic status colors, list rows, branding, native disclosure and hints |
| Feedback | `AppInfoBar`, `AppProgressRing`, `AppProgressBar`, `AppLoadingState`, `AppEmptyState`, `AppErrorState`, `AppSkeleton` | Status messages, progress, retry/empty action slots and loading placeholders |
| Overlay | `AppDialog` | Scrollable content and wrapping actions; the caller owns showing and dismissing it |

## Ownership

These widgets render presentation values and report interaction through callbacks.
They do not import a feature, repository, Formz model, Bloc, service locator or
router. They perform no API/storage work, validation, search debouncing or task
execution. A feature Bloc owns those decisions and passes the resulting state.
There are no custom stateful widgets or `setState` calls in this package.

Fluent/Flutter controls retain their native editing, focus, animation, menu and
disclosure behavior. `AppExpander.initiallyExpanded` sets the native expander's
initial state; `onChanged` reports subsequent expansion. It is not a controlled
feature-state input.

For prefilled text, supply a controller owned by the calling presentation
lifecycle. Keep that controller stable across rebuilds and dispose it with its
owner. Without a controller, the native text control owns its editing buffer.
`AppSearchField.onClear` reports an action; it does not clear the supplied
controller or perform a search. `AppPasswordField.onObscureTextChanged` reports
the requested `obscureText` value; the caller supplies the updated value.

## Examples

```dart
AppButton(
  label: 'Sign in',
  isLoading: state.isSubmitting,
  onPressed: () => bloc.add(const LoginSubmitted()),
)

AppTextField(
  label: 'Email address',
  placeholder: 'you@example.com',
  keyboardType: TextInputType.emailAddress,
  autofillHints: const [AutofillHints.username],
  errorText: state.emailError,
  onChanged: (email) => bloc.add(LoginEmailChanged(email)),
)

AppDropdown<ThemeMode>(
  label: 'Appearance',
  value: state.mode,
  options: const [
    AppSelectOption(value: ThemeMode.system, label: 'Use system setting'),
    AppSelectOption(value: ThemeMode.light, label: 'Light'),
    AppSelectOption(value: ThemeMode.dark, label: 'Dark'),
  ],
  onChanged: (mode) => bloc.add(AppearanceThemeSelected(mode)),
)

const AppSection(
  title: 'Profile',
  description: 'Your public account information.',
  child: AppCard(
    child: AppListTile(
      title: 'Alex Morgan',
      subtitle: 'alex@example.com',
      leading: AppAvatar(label: 'Alex Morgan', initials: 'AM'),
    ),
  ),
)
```

Use `AppSelectOption<T>` for both dropdowns and radio groups. Option values must
be unique, and a non-null selection must exist in the options. A null callback
disables an input/action. Loading buttons preserve their text and disable
activation regardless of the supplied callback.

## Styling and accessibility

- `AppTheme` supplies Fluent light/dark themes. Typography and semantic colors
  come from the active Fluent theme, including button foregrounds and status
  surfaces. Components do not encode a light-only palette.
- `AppSpacing` and `AppRadius` define shared layout tokens. `AppControlSize`
  provides minimum heights of 32, 40 and 48 logical pixels; use `large` for touch
  actions. Controls can grow vertically with scaled text.
- Inputs share labels and validation feedback through `AppField`. Error text is
  announced as a live region. Password fields disable suggestions/autocorrection;
  optional visibility controls keep an accessible label.
- Icon buttons require tooltip text. Progress values use fractions from `0` to
  `1` and announce percentages; null means indeterminate. Skeletons are decorative
  and should accompany an announced loading state.
- Titles expose heading semantics. Labels, tooltip strings, loading/retry text
  and picker locales are caller-configurable for localization.
- Text fields, dropdowns, sections and page content expect a bounded width.
  `AppPageBody` supplies responsive gutters and scrolling. Put fixed-size display
  components such as an avatar or progress ring in an `Align`/`Center` when used
  inside a stretched column.

The component tests cover keyboard/mouse activation, loading suppression,
controlled selections, password editing across rebuilds, validation feedback,
theme foregrounds, progress semantics and dialog actions. The layout catalog
exercises light/dark themes at 320 and 1280 logical pixels with 200% text.

Login, home, preferences and the navigation shell use these components. The old
`PageBody`, `SectionCard`, `BrandHeader` and `EnvironmentBadge` names have been
replaced with `AppPageBody`, `AppCard`, `AppBrandHeader` and `AppBadge`.
