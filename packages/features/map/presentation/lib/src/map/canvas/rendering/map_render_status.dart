/// Native rendering observations. User-facing messages belong to view state.
enum MapRenderStatus {
  waitingForMap,
  loadingStyle,
  ready,
  styleTimeout,
  renderingFailure,
}
