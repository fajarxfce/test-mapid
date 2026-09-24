import 'package:fluent_ui/fluent_ui.dart';
import 'package:map_presentation/src/map/widgets/map_bindings.dart';
import 'package:map_presentation/src/map/widgets/map_canvas.dart';
import 'package:map_presentation/src/map/widgets/map_header.dart';
import 'package:map_presentation/src/map/widgets/map_viewport.dart';

class MapView extends StatelessWidget {
  const MapView({this.canvas = const MapCanvas(), super.key});
  final Widget canvas;
  @override
  Widget build(BuildContext context) => MapBindings(
    child: ScaffoldPage(
      padding: EdgeInsets.zero,
      content: SafeArea(
        child: Column(
          children: [
            const MapHeader(),
            Expanded(child: MapViewport(canvas: canvas)),
          ],
        ),
      ),
    ),
  );
}
