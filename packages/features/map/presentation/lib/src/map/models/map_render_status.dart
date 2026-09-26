/// Native view observations. User-facing messages belong to page state.
enum MapRenderStatus {
  waitingForMap,
  loadingStyle,
  ready,
  styleTimeout,
  renderingFailure,
}
