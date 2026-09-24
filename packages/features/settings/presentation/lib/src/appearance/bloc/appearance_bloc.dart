import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_common/core_common.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/src/appearance/bloc/appearance_event.dart';
import 'package:settings_presentation/src/appearance/bloc/appearance_state.dart';

@lazySingleton
final class AppearanceBloc extends Bloc<AppearanceEvent, AppearanceState> {
  AppearanceBloc(this._load, this._save) : super(const AppearanceState()) {
    on<AppearanceEvent>(_onEvent, transformer: sequential());
  }
  final LoadTheme _load;
  final SaveTheme _save;

  Future<void> _onEvent(
    AppearanceEvent event,
    Emitter<AppearanceState> emit,
  ) async {
    switch (event) {
      case AppearanceStarted():
        final result = await _load();
        emit(switch (result) {
          Success<AppThemeMode>(:final value) => state.copyWith(
            initialized: true,
            mode: ThemeMode.values.byName(value.name),
          ),
          FailureResult<AppThemeMode>(:final failure) => state.copyWith(
            initialized: true,
            error: failure.message,
          ),
        });
      case AppearanceThemeSelected(:final mode):
        if (mode == null) return;
        emit(state.copyWith(mode: mode, saving: true, error: null));
        final result = await _save(AppThemeMode.values.byName(mode.name));
        emit(
          state.copyWith(
            saving: false,
            error: switch (result) {
              FailureResult<void>(:final failure) => failure.message,
              Success<void>() => null,
            },
          ),
        );
    }
  }

  @override
  @disposeMethod
  Future<void> close() => super.close();
}
