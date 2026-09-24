enum LoginProvider {
  google('Continue with Google'),
  github('Continue with GitHub');

  const LoginProvider(this.label);
  final String label;
}
