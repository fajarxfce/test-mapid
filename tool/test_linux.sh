#!/usr/bin/env bash
set -euo pipefail
# Isolate the test keyring and preferences from the developer's desktop session.
FLUENT_TEST_DATA=$(mktemp -d /tmp/fluent-keyring.XXXXXX)
trap 'rm -rf -- "$FLUENT_TEST_DATA"' EXIT
export XDG_DATA_HOME="$FLUENT_TEST_DATA"
cd "$(dirname "$0")/../apps/fluent_starter"
dbus-run-session -- bash -euo pipefail -c '
  printf "%s" "fluent-disposable-test-keyring" | gnome-keyring-daemon --unlock --components=secrets >/dev/null
  xvfb-run -a flutter test integration_test/app_flow_test.dart -d linux --flavor dev --dart-define=FLAVOR=dev --dart-define=BACKEND=demo
'
