import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';

/// Presentation wiring: forward changed data without coupling the two Blocs.
class MapBindings extends StatelessWidget {
  const MapBindings({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => BlocListener<MapBloc, MapState>(
    listenWhen: (previous, current) => previous.content != current.content,
    listener: (context, state) => context.read<MapCanvasBloc>().add(
      MapCanvasContentChanged(state.content),
    ),
    child: child,
  );
}
