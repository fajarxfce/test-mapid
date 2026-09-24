import 'package:dio/dio.dart';
import 'package:identity_data/src/oauth/oauth_browser.dart';

/// Follows the in-process demo broker's redirect without opening a provider site.
final class DemoOAuthBrowser implements OAuthBrowser {
  DemoOAuthBrowser(this._dio);
  final Dio _dio;

  @override
  Future<String> authenticate(Uri authorizationUri, Uri redirectUri) async {
    final response = await _dio.getUri<String>(
      authorizationUri,
      options: Options(
        responseType: ResponseType.plain,
        followRedirects: false,
        validateStatus: (status) => status == 302,
        extra: {'authenticated': false},
      ),
    );
    return response.headers.value('location') ?? '';
  }
}
