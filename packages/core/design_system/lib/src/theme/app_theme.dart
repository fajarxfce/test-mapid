import 'package:fluent_ui/fluent_ui.dart';

abstract final class AppTheme {
  static FluentThemeData light() => FluentThemeData(
    brightness: Brightness.light,
    accentColor: Colors.blue,
    visualDensity: VisualDensity.standard,
  );
  static FluentThemeData dark() => FluentThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.blue,
    visualDensity: VisualDensity.standard,
  );
}
