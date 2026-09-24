import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default('') String displayName,
    @Default('') String email,
    @Default('') String environment,
    @Default(false) bool busy,
    @Default(false) bool isDemo,
    String? message,
  }) = _HomeState;
}
