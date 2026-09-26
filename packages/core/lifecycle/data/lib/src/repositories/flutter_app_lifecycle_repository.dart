import 'package:core_lifecycle_data/src/datasources/app_lifecycle_data_source.dart';
import 'package:core_lifecycle_domain/core_lifecycle_domain.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AppLifecycleRepository)
final class FlutterAppLifecycleRepository implements AppLifecycleRepository {
  const FlutterAppLifecycleRepository(this._source);
  final AppLifecycleDataSource _source;

  @override
  Stream<bool> watchForeground() => _source.watchForeground();
}
