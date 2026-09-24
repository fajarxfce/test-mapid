/// Opens an authorization URL and returns the full redirect delivered by the browser.
abstract interface class OAuthBrowser {
  Future<String> authenticate(Uri authorizationUri, Uri redirectUri);
}
