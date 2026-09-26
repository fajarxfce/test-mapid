// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_lifecycle_data/src/datasources/app_lifecycle_data_source.dart'
    as _i1057;
import 'package:core_lifecycle_data/src/datasources/flutter_app_lifecycle_data_source.dart'
    as _i444;
import 'package:core_lifecycle_data/src/repositories/flutter_app_lifecycle_repository.dart'
    as _i783;
import 'package:core_lifecycle_domain/core_lifecycle_domain.dart' as _i705;
import 'package:injectable/injectable.dart' as _i526;

class CoreLifecycleDataPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i1057.AppLifecycleDataSource>(
      () => const _i444.FlutterAppLifecycleDataSource(),
    );
    gh.lazySingleton<_i705.AppLifecycleRepository>(
      () => _i783.FlutterAppLifecycleRepository(
        gh<_i1057.AppLifecycleDataSource>(),
      ),
    );
  }
}
