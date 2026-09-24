/// A credential issuance, captured by the HTTP request using it.
///
/// Instances intentionally use identity equality: signing in again with the same
/// token text must still make responses from the previous session obsolete.
final class AccessCredential {
  AccessCredential(this.token);

  final String token;

  @override
  String toString() => 'AccessCredential([redacted])';
}
