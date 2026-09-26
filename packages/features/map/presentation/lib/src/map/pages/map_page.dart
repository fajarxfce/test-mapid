import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:map_presentation/src/map/canvas/map_canvas.dart';
import 'package:map_presentation/src/map/widgets/map_header.dart';
import 'package:map_presentation/src/map/widgets/map_viewport.dart';

@RoutePage()
class MapPage extends StatelessWidget {
  const MapPage({super.key, Widget? canvas})
    : canvas = canvas ?? const MapCanvas();
  final Widget canvas;

  @override
  Widget build(BuildContext context) => ScaffoldPage(
    padding: EdgeInsets.zero,
    content: SafeArea(
      child: Column(
        children: [
          const MapHeader(),
          Expanded(child: MapViewport(canvas: canvas)),
        ],
      ),
    ),
  );
}
