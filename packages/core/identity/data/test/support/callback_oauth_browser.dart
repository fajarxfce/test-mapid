import 'package:identity_data/identity_data.dart';

final class CallbackOAuthBrowser implements OAuthBrowser {
  CallbackOAuthBrowser(this.callback);
  final Future<String> Function(Uri authorization, Uri redirect) callback;

  @override
  Future<String> authenticate(Uri authorizationUri, Uri redirectUri) =>
      callback(authorizationUri, redirectUri);
}
