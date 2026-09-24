import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_testing/core_testing.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/settings_presentation.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository repository;
  late AppearanceBloc bloc;
  setUp(() {
    repository = MockSettingsRepository();
    bloc = AppearanceBloc(LoadTheme(repository), SaveTheme(repository));
  });
  tearDown(() => bloc.close());

  test(
    'startup loads the saved domain preference into presentation state',
    () async {
      when(repository.loadTheme)
          .thenAnswer((_) async => const Success(AppThemeMode.dark));
      final ready = bloc.stream.firstWhere((state) => state.initialized);
      bloc.add(const AppearanceStarted());
      expect((await ready).mode, ThemeMode.dark);
    },
  );

  test(
    'failed startup keeps system appearance and finishes initialization',
    () async {
      when(repository.loadTheme).thenAnswer(
        (_) async =>
            const FailureResult(Failure(FailureKind.storage, 'Unavailable')),
      );
      final ready = bloc.stream.firstWhere((state) => state.initialized);
      bloc.add(const AppearanceStarted());
      final state = await ready;
      expect(state.mode, ThemeMode.system);
      expect(state.error, 'Unavailable');
    },
  );

  test('failed persistence keeps the chosen theme for this session', () async {
    when(() => repository.saveTheme(AppThemeMode.light)).thenAnswer(
      (_) async =>
          const FailureResult(Failure(FailureKind.storage, 'Cannot save')),
    );
    final saved = bloc.stream.firstWhere(
      (state) => state.mode == ThemeMode.light && !state.saving,
    );
    bloc.add(const AppearanceThemeSelected(ThemeMode.light));
    final state = await saved;
    expect(state.mode, ThemeMode.light);
    expect(state.error, 'Cannot save');
  });

  test(
    'rapid selections persist in event order and ignore empty selection',
    () async {
      final firstWrite = Completer<Result<void>>();
      when(() => repository.saveTheme(AppThemeMode.dark))
          .thenAnswer((_) => firstWrite.future);
      when(() => repository.saveTheme(AppThemeMode.light))
          .thenAnswer((_) async => const Success(null));
      final writing = bloc.stream.firstWhere((state) => state.saving);
      bloc.add(const AppearanceThemeSelected(null));
      bloc.add(const AppearanceThemeSelected(ThemeMode.dark));
      bloc.add(const AppearanceThemeSelected(ThemeMode.light));
      await writing;
      verifyNever(() => repository.saveTheme(AppThemeMode.light));
      final saved = bloc.stream.firstWhere(
        (state) => state.mode == ThemeMode.light && !state.saving,
      );
      firstWrite.complete(const Success(null));
      await saved;
      verifyInOrder([
        () => repository.saveTheme(AppThemeMode.dark),
        () => repository.saveTheme(AppThemeMode.light),
      ]);
    },
  );
}
