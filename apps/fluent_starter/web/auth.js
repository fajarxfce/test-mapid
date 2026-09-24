const callback = window.location.href;
window.history.replaceState(null, '', window.location.pathname);
if (window.opener) {
  window.opener.postMessage({'flutter-web-auth-2': callback}, window.location.origin);
  window.close();
}
