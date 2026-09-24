import 'package:fluent_ui/fluent_ui.dart';

sealed class AppearanceEvent {
  const AppearanceEvent();
}

final class AppearanceStarted extends AppearanceEvent {
  const AppearanceStarted();
}

final class AppearanceThemeSelected extends AppearanceEvent {
  const AppearanceThemeSelected(this.mode);
  final ThemeMode? mode;
}
