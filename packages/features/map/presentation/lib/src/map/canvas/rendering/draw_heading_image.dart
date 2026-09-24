import 'dart:typed_data';
import 'dart:ui';

/// Map-aligned north arrow; the symbol layer rotates it from the bearing value.
Future<Uint8List> drawHeadingImage({required double pixelRatio}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  final arrow = Path()
    ..moveTo(32, 2)
    ..lineTo(17, 25)
    ..lineTo(32, 19)
    ..lineTo(47, 25)
    ..close();
  canvas.drawPath(arrow, Paint()..color = const Color(0xFF1468D4));
  canvas.drawPath(
    arrow,
    Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
  final picture = recorder.endRecording();
  final size = (64 * pixelRatio).ceil();
  final image = await picture.toImage(size, size);
  try {
    final data = await image.toByteData(format: ImageByteFormat.png);
    return data!.buffer.asUint8List();
  } finally {
    image.dispose();
    picture.dispose();
  }
}
