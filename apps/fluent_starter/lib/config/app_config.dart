import 'package:fluent_starter/config/app_flavor.dart';
import 'package:flutter/services.dart';

final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiKey,
    required this.layerId,
    required this.projectId,
  });
  final AppFlavor flavor;
  final String apiKey;
  final String layerId;
  final String projectId;

  factory AppConfig.fromEnvironment() => AppConfig.parse(
    flavor: const String.fromEnvironment('FLAVOR', defaultValue: 'dev'),
    nativeFlavor: appFlavor,
    apiKey: const String.fromEnvironment('MAPID_API_KEY'),
    layerId: const String.fromEnvironment('MAPID_LAYER_ID'),
    projectId: const String.fromEnvironment('MAPID_PROJECT_ID'),
  );

  factory AppConfig.parse({
    required String flavor,
    required String apiKey,
    required String layerId,
    required String projectId,
    String? nativeFlavor,
  }) {
    if (nativeFlavor != null && nativeFlavor != flavor) {
      throw const FormatException('Native flavor and FLAVOR must match.');
    }
    for (final entry in {
      'MAPID_API_KEY': apiKey,
      'MAPID_LAYER_ID': layerId,
      'MAPID_PROJECT_ID': projectId,
    }.entries) {
      if (entry.value.trim().isEmpty) {
        throw FormatException(
          'Missing ${entry.key}. Configure the root .env file before running.',
        );
      }
    }
    return AppConfig(
      flavor: AppFlavor.values.byName(flavor),
      apiKey: apiKey.trim(),
      layerId: layerId.trim(),
      projectId: projectId.trim(),
    );
  }
}
