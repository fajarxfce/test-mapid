enum AppControlSize {
  compact(32),
  standard(40),
  large(48);

  const AppControlSize(this.minHeight);
  final double minHeight;
}
