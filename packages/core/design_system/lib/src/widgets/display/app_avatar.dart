import 'package:core_design_system/src/tokens/app_text_variant.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.label,
    this.initials,
    this.image,
    this.size = 40,
    super.key,
  });
  final String label;
  final String? initials;
  final ImageProvider? image;
  final double size;
  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: initials == null
          ? Icon(FluentIcons.contact, size: size * 0.45)
          : Padding(
              padding: const EdgeInsets.all(4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppText(initials!, variant: AppTextVariant.bodyStrong),
              ),
            ),
    );
    return Semantics(
      image: true,
      label: label,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: ClipOval(
            child: ColoredBox(
              color: FluentTheme.of(context)
                  .resources
                  .controlAltFillColorSecondary,
              child: image == null
                  ? fallback
                  : Image(
                      image: image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => fallback,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
