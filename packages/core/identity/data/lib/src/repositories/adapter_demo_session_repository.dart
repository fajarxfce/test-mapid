import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:identity_data/src/datasources/demo/demo_adapter.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DemoSessionRepository)
final class AdapterDemoSessionRepository implements DemoSessionRepository {
  AdapterDemoSessionRepository(@Named(mainApi) this._dio);
  final Dio _dio;

  @override
  Future<Result<void>> expireSession() async {
    final adapter = _dio.httpClientAdapter;
    if (adapter is! DemoAdapter) {
      return const FailureResult(
        Failure(
          FailureKind.unexpected,
          'Session simulation is available only in demo mode.',
        ),
      );
    }
    adapter.expireSession = true;
    return const Success(null);
  }
}
