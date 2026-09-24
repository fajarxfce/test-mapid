abstract interface class CompassDataSource {
  /// Magnetic heading in degrees, or null when the sensor cannot provide one.
  Stream<double?> watch();
}
