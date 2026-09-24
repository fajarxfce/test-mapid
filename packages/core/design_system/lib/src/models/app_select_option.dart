/// Presentation label and stable value for dropdowns and radio groups.
class AppSelectOption<T> {
  const AppSelectOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });
  final T value;
  final String label;
  final bool enabled;
}
