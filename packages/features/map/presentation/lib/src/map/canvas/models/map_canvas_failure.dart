enum MapCanvasFailure {
  styleTimeout,
  rendering;

  String get message => switch (this) {
    styleTimeout =>
      'Basemap belum dapat dimuat. Periksa koneksi internet lalu coba lagi.',
    rendering => 'Peta belum dapat diperbarui. Coba muat ulang basemap.',
  };
}
