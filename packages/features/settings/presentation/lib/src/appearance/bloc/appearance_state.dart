import 'package:fluent_ui/fluent_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'appearance_state.freezed.dart';

@freezed
abstract class AppearanceState with _$AppearanceState {
  const factory AppearanceState({
    @Default(ThemeMode.system) ThemeMode mode,
    @Default(false) bool initialized,
    @Default(false) bool saving,
    String? error,
  }) = _AppearanceState;
}
