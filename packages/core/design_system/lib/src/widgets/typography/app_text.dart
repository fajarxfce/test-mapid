import 'package:core_design_system/src/tokens/app_text_variant.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    this.variant = AppTextVariant.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
    this.semanticsLabel,
    super.key,
  });
  final String data;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool selectable;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;
    final style = switch (variant) {
      AppTextVariant.caption => typography.caption,
      AppTextVariant.body => typography.body,
      AppTextVariant.bodyStrong => typography.bodyStrong,
      AppTextVariant.subtitle => typography.subtitle,
      AppTextVariant.title => typography.title,
      AppTextVariant.titleLarge => typography.titleLarge,
      AppTextVariant.display => typography.display,
    }?.copyWith(color: color ?? DefaultTextStyle.of(context).style.color);
    return Semantics(
      header: switch (variant) {
        AppTextVariant.subtitle ||
        AppTextVariant.title ||
        AppTextVariant.titleLarge ||
        AppTextVariant.display => true,
        _ => false,
      },
      child: selectable
          ? SelectableText(
              data,
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              semanticsLabel: semanticsLabel,
            )
          : Text(
              data,
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
              semanticsLabel: semanticsLabel,
            ),
    );
  }
}
