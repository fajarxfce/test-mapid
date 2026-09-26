import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:map_presentation/src/map/models/place_details.dart';

class PlaceDetailsPopup extends StatelessWidget {
  const PlaceDetailsPopup({
    required this.details,
    required this.onClose,
    super.key,
  });
  final PlaceDetails details;
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) => AppCard(
    backgroundColor: FluentTheme.of(context)
        .resources
        .solidBackgroundFillColorBase,
    padding: const EdgeInsets.all(18),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: AppText(
                  'DESTINASI WISATA',
                  variant: AppTextVariant.caption,
                  color: Color(0xFF16803C),
                ),
              ),
              AppIconButton(
                icon: FluentIcons.cancel,
                tooltip: 'Tutup informasi tempat',
                onPressed: onClose,
              ),
            ],
          ),
          AppText(details.name, variant: AppTextVariant.subtitle),
          const SizedBox(height: 14),
          const AppText('Alamat', variant: AppTextVariant.bodyStrong),
          const SizedBox(height: 4),
          AppText(details.address),
          if (details.area.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppText(details.area, variant: AppTextVariant.caption),
          ],
          const SizedBox(height: 12),
          AppText('Periode ${details.period}', variant: AppTextVariant.caption),
          AppText(details.coordinates, variant: AppTextVariant.caption),
        ],
      ),
    ),
  );
}
