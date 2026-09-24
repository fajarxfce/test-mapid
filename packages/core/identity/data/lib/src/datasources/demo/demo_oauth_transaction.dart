final class DemoOAuthTransaction {
  const DemoOAuthTransaction({
    required this.provider,
    required this.challenge,
    required this.redirectUri,
  });

  final String provider;
  final String challenge;
  final String redirectUri;
}
