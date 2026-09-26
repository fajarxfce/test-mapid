/// Native view observations. User-facing messages belong to page state.
enum MapCanvasStatus {
  waitingForMap,
  loadingStyle,
  ready,
  creationTimeout,
  styleTimeout,
  renderingFailure,
}
