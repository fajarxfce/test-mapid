import 'dart:io';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  final cases = <Object, FailureKind>{
    const SocketException('private DNS failure'): FailureKind.network,
    const HttpException('private connection failure'): FailureKind.network,
    const OSError('private OS error', 54): FailureKind.network,
    const HandshakeException('private handshake failure'): FailureKind.security,
    const TlsException('private TLS failure'): FailureKind.security,
    const CertificateException('private certificate failure'):
        FailureKind.security,
  };

  for (final entry in cases.entries) {
    test(
      '${entry.key.runtimeType} is classified directly and through Dio wrappers',
      () async {
        final options = RequestOptions(path: '/resource');
        for (final error in [
          entry.key,
          DioException(requestOptions: options, error: entry.key),
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: entry.key,
          ),
        ]) {
          final result = await safeApiCall<void>(() => throw error);
          final failure = (result as FailureResult<void>).failure;
          expect(failure.kind, entry.value);
          expect(failure.message, isNot(contains('private')));
        }
      },
    );
  }
}
