import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_common/core_common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_presentation/src/home/bloc/home_event.dart';
import 'package:home_presentation/src/home/bloc/home_state.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@injectable
final class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    WatchSession watch,
    GetCurrentSession current,
    this._restore,
    this._logout,
    this._expire,
    AppEnvironment environment,
  ) : super(
        HomeState(
          displayName: current().user?.displayName ?? '',
          email: current().user?.email ?? '',
          environment: environment.label,
          isDemo: environment.isDemo,
        ),
      ) {
    on<HomeEvent>(_onEvent, transformer: sequential());
    _subscription = watch().listen(
      (session) => add(HomeSessionChanged(session)),
    );
  }

  final RestoreSession _restore;
  final Logout _logout;
  final ExpireDemoSession _expire;
  late final StreamSubscription<Session> _subscription;

  Future<void> _onEvent(HomeEvent event, Emitter<HomeState> emit) async {
    switch (event) {
      case HomeSessionCheckRequested():
        await _check(emit, showSuccess: true);
      case HomeLogoutRequested():
        emit(state.copyWith(busy: true, message: null));
        final result = await _logout();
        if (emit.isDone) return;
        emit(
          state.copyWith(
            busy: false,
            message: switch (result) {
              FailureResult<void>(:final failure) => failure.message,
              Success<void>() => null,
            },
          ),
        );
      case HomeSessionExpiryRequested():
        if (!state.isDemo) return;
        emit(state.copyWith(busy: true, message: null));
        final result = await _expire();
        if (emit.isDone) return;
        if (result case FailureResult<void>(:final failure)) {
          emit(state.copyWith(busy: false, message: failure.message));
          return;
        }
        await _check(emit, showSuccess: false);
      case HomeSessionChanged(:final session):
        emit(
          state.copyWith(
            displayName: session.user?.displayName ?? '',
            email: session.user?.email ?? '',
          ),
        );
    }
  }

  Future<void> _check(
    Emitter<HomeState> emit, {
    required bool showSuccess,
  }) async {
    emit(state.copyWith(busy: true, message: null));
    final result = await _restore();
    if (emit.isDone) return;
    emit(
      state.copyWith(
        busy: false,
        message: switch (result) {
          FailureResult<User?>(:final failure) => failure.message,
          Success<User?>() =>
            showSuccess ? 'Your session is up to date.' : null,
        },
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
