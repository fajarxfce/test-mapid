import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:identity_data/src/datasources/demo/demo_oauth_transaction.dart';

/// Deterministic in-process HTTP backend; never contacts the network.
final class DemoAdapter implements HttpClientAdapter {
  DemoAdapter({this.latency = const Duration(milliseconds: 350)});
  final Duration latency;
  bool expireSession = false;
  int _nextCode = 0;
  final _oauthCodes = <String, DemoOAuthTransaction>{};
  static const _providerUsers = <String, Map<String, Object>>{
    'google': {
      'id': 'demo-google-user',
      'email': 'google@example.com',
      'display_name': 'Google Demo User',
    },
    'github': {
      'id': 'demo-github-user',
      'email': 'github@example.com',
      'display_name': 'GitHub Demo User',
    },
  };
  static const user = <String, Object>{
    'id': 'demo-user',
    'email': 'demo@example.com',
    'display_name': 'Alex Morgan',
  };
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(latency);
    ResponseBody reply(int status, Object data) => ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
    final segments = options.uri.pathSegments;
    if (segments.length == 4 &&
        segments[0] == 'auth' &&
        segments[1] == 'oauth') {
      final provider = segments[2];
      final providerUser = _providerUsers[provider];
      if (providerUser == null) {
        return reply(404, {'message': 'Unknown provider'});
      }
      if (segments[3] == 'authorize' && options.method == 'GET') {
        final query = options.uri.queryParameters;
        final redirect = Uri.tryParse(query['redirect_uri'] ?? '');
        final state = query['state'];
        final challenge = query['code_challenge'];
        if (redirect == null ||
            !redirect.hasScheme ||
            state == null ||
            challenge == null ||
            query['code_challenge_method'] != 'S256') {
          return reply(400, {'message': 'Invalid authorization request'});
        }
        final code = 'demo-code-${++_nextCode}';
        _oauthCodes[code] = DemoOAuthTransaction(
          provider: provider,
          challenge: challenge,
          redirectUri: redirect.toString(),
        );
        return ResponseBody.fromString(
          '',
          302,
          headers: {
            'location': [
              redirect
                  .replace(queryParameters: {'code': code, 'state': state})
                  .toString(),
            ],
          },
        );
      }
      if (segments[3] == 'exchange' && options.method == 'POST') {
        final raw = options.data;
        final data =
            (raw is String ? jsonDecode(raw) : raw) as Map<String, dynamic>;
        final transaction = _oauthCodes.remove(data['code']);
        final verifier = data['code_verifier'];
        if (transaction == null ||
            transaction.provider != provider ||
            verifier is! String ||
            transaction.redirectUri != data['redirect_uri'] ||
            base64Url
                    .encode(sha256.convert(utf8.encode(verifier)).bytes)
                    .replaceAll('=', '') !=
                transaction.challenge) {
          return reply(401, {
            'message': 'Invalid or consumed authorization code',
          });
        }
        expireSession = false;
        return reply(200, {
          'access_token': 'demo-$provider-access-token',
          'user': providerUser,
        });
      }
    }
    if (options.path == '/auth/login' && options.method == 'POST') {
      final raw = options.data;
      final data =
          (raw is String ? jsonDecode(raw) : raw) as Map<String, dynamic>;
      if (data['email'] == 'timeout@example.com') {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        );
      }
      if (data['email'] == 'server@example.com') {
        return reply(503, {'message': 'Unavailable'});
      }
      if (data['email'] != 'demo@example.com' ||
          data['password'] != 'Demo123!') {
        return reply(401, {'message': 'Invalid credentials'});
      }
      expireSession = false;
      return reply(200, {'access_token': 'demo-access-token', 'user': user});
    }
    if (options.path == '/auth/me' && options.method == 'GET') {
      if (!expireSession) {
        for (final entry in _providerUsers.entries) {
          if (options.headers['Authorization'] ==
              'Bearer demo-${entry.key}-access-token') {
            return reply(200, entry.value);
          }
        }
      }
      if (expireSession ||
          options.headers['Authorization'] != 'Bearer demo-access-token') {
        return reply(401, {'message': 'Session expired'});
      }
      return reply(200, user);
    }
    return reply(404, {'message': 'Not found'});
  }

  @override
  void close({bool force = false}) {}
}
