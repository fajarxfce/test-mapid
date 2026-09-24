import 'package:core_location_data/src/datasources/flutter_compass_data_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<void> settle() => Future<void>.delayed(Duration.zero);
  const channel = MethodChannel('hemanthraj/flutter_compass');
  const codec = StandardMethodCodec();
  late List<String> calls;
  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test(
    'normalizes and limits sensor readings, then unregisters on cancel',
    () async {
      final headings = <double?>[];
      final subscription = const FlutterCompassDataSource().watch().listen(
        headings.add,
      );
      await settle();
      expect(headings, [null]);
      void send(double heading, double accuracy) =>
          TestDefaultBinaryMessengerBinding.instance.channelBuffers.push(
            channel.name,
            codec.encodeSuccessEnvelope([heading, 0.0, accuracy]),
            (_) {},
          );
      send(-1.0, 15.0);
      await settle();
      expect(headings.last, 359);
      for (var i = 0; i < 20; i++) {
        send(i.toDouble(), 15.0);
      }
      await settle();
      expect(headings.length, lessThan(20));
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(headings.last, 19);
      send(30, -1);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(
        headings.last,
        isNull,
        reason: 'Unknown accuracy must not report a reliable bearing',
      );
      await subscription.cancel();
      await settle();
      expect(calls, ['listen', 'cancel']);
    },
  );

  test('sensor failure degrades to no compass heading', () async {
    final headings = <double?>[];
    final subscription = const FlutterCompassDataSource().watch().listen(
      headings.add,
    );
    await settle();
    TestDefaultBinaryMessengerBinding.instance.channelBuffers.push(
      channel.name,
      codec.encodeErrorEnvelope(code: 'NO_SENSOR'),
      (_) {},
    );
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(headings, [null]);
    await subscription.cancel();
    await settle();
  });
}
