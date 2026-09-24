# Android debugging from a VPS

In a Zed remote project or VS Code Remote SSH window, Flutter builds and the debug adapter run on the VPS. The application runs on the phone. The phone must appear in `flutter devices` **on the VPS** for installation, logs, breakpoints, and hot reload. Plugging the phone into the laptop does not automatically expose it to the remote project.

Choose the fixed-port workflow when the phone is a reachable WireGuard peer and USB access through the laptop is available. For access through a laptop without a phone VPN, use the Wireless debugging and SSH tunnel workflow below.

## Fixed ADB port over WireGuard

This workspace's phone uses VPN address `10.77.77.3`. The `Android via WireGuard` editor presets select `10.77.77.3:5555`; update their device address for a different peer. This workflow uses classic ADB TCP with the phone's RSA-key authorization. Traffic between the VPS and phone travels inside WireGuard; it does not use Android's changing Wireless debugging pairing ports.

Connect the phone to the laptop over USB, enable **USB debugging**, and allow the laptop's authorization prompt on the phone. Install [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools) on the laptop if `adb` is unavailable. From a **local laptop terminal**, run:

```sh
adb devices -l
adb -d tcpip 5555
```

The USB device must be listed as `device`, not `unauthorized`. The second command should report `restarting in TCP mode port: 5555`. If more than one USB Android device is connected, replace `-d` with `-s <phone-usb-serial>`. In PowerShell, use `./adb.exe` when running from an extracted Platform-Tools directory that is not on `PATH`.

From the **VPS**, run the following commands. If `adb` is not on `PATH`, use `<Android SDK>/platform-tools/adb` instead; `flutter doctor -v` prints the SDK location.

```sh
adb connect 10.77.77.3:5555
adb devices -l
flutter devices
```

Unlock the phone and accept the VPS's debugging authorization prompt if it appears. Its key is different from the laptop's USB key. If ADB reports `unauthorized`, accept the prompt and reconnect. Once ADB reports `device`, choose `Debug | dev | Android via WireGuard` in Zed or VS Code. Staging and prod presets are also available. For a terminal run:

```sh
dart run tool/app.dart run android dev --device=10.77.77.3:5555
```

The cable can remain connected or be removed after TCP mode is enabled. Repeat the USB `tcpip 5555` command after a phone reboot or an ADB daemon reset if the TCP listener is no longer available. Port `5555` is fixed for this mode; it is not a promise that the listener survives rebooting. Keep Wireless debugging off when using this workflow to avoid mixing two ADB transports.

After stopping the debug session, turn off TCP mode with `adb -s 10.77.77.3:5555 usb` from the VPS, or `adb -d usb` from the laptop with USB connected. This resets the phone's ADB daemon to USB mode. `adb disconnect` alone closes the VPS connection but leaves the phone's TCP listener running. Classic ADB can also listen on the phone's Wi-Fi interface; use a trusted network and stop TCP mode when finished.

## Wireless debugging through an SSH tunnel

Android 11 and newer, including Android 16, support Wireless debugging. Keep the phone and laptop on the same Wi-Fi network. This workflow only needs an SSH client on the laptop; Flutter, the Android SDK, and ADB stay on the VPS.

## Prepare the phone

Enable **Developer options → Wireless debugging**, and allow the current Wi-Fi network. Record the **IP address & port** on that screen: this is the connection endpoint. Then open **Pair device with pairing code** and record its IP, pairing port, and code. Keep this dialog open until pairing finishes.

The pairing port and connection port are different. For the example below, assume:

| Purpose | Example phone endpoint | Forwarded endpoint on VPS |
|---|---|---|
| ADB connection | `192.168.1.50:39877` | `127.0.0.1:15555` |
| Pairing dialog | `192.168.1.50:37111` | `127.0.0.1:15556` |

Replace the example IP and phone ports with the values currently shown on the phone. Keep VPS ports `15555` and `15556` to match the editor presets.

## Open the tunnel from the laptop

Run this in a **local laptop terminal**, outside the remote Zed/VS Code terminal. The same one-line command works with OpenSSH in PowerShell, Linux, and macOS:

```sh
ssh -N -T -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -R 127.0.0.1:15555:192.168.1.50:39877 -R 127.0.0.1:15556:192.168.1.50:37111 user@vps
```

Use the SSH host/alias, user, and authentication options you already use for the VPS. If the laptop uses WireGuard to reach the VPS, use its VPN address or SSH alias. Keep this terminal open throughout debugging; silence after authentication is normal. The VPS's SSH service must allow remote TCP forwarding. The forwarded ADB endpoints bind to loopback and need no public firewall ports.

## Pair and connect from the VPS

Use the remote editor terminal. Run these as the same user that runs Flutter and the remote editor, so they share ADB's pairing key and server. Add the SDK's `platform-tools` directory to this shell's `PATH` if `adb` is not found; `flutter doctor -v` prints the Android SDK location.

```sh
adb pair 127.0.0.1:15556
```

Enter the code in the terminal prompt. After pairing succeeds:

```sh
adb connect 127.0.0.1:15555
adb devices -l
flutter devices
```

The phone should be listed as `127.0.0.1:15555` with ADB status `device`. Pairing alone does not connect the transport: use `adb connect` explicitly because Wi-Fi discovery does not cross the SSH tunnel. ADB's server runs on the VPS, so Flutter can create its VM-service forwarding there automatically; no separate VM-service tunnel is needed.

## Run or debug

In Zed, use `debugger: start` → `Debug | dev | Android via SSH tunnel`. In VS Code's Remote SSH window, select the same launch preset and press F5. Both editors also have staging and prod variants. Each preset loads the GEO MAPID configuration from the root `.env` file.

For a terminal run from the repository root:

```sh
dart run tool/app.dart run android dev --device=127.0.0.1:15555
```

Use `r` for hot reload, `R` for hot restart, and `q` to quit a terminal run. The existing `Android: Run | dev` task also works when only one Android device is connected. Stop a terminal run before starting an editor debug session for the same app.

To build a debug APK without a connected phone:

```sh
dart run tool/app.dart build android dev --smoke
```

Output: `apps/fluent_starter/build/app/outputs/flutter-apk/app-dev-debug.apk`. Building or manually installing an APK does not itself start an attached debug session.

## Reconnect and disconnect

Pairing is normally retained for the VPS user. The phone's IP and connection port can change after Wi-Fi changes, rebooting, or toggling Wireless debugging. Restart the laptop tunnel with the current phone connection endpoint and run `adb connect 127.0.0.1:15555` again. Once paired, the tunnel only needs the `15555` connection forward. Keep the editor presets unchanged.

If pairing fails, reopen the phone's pairing dialog, update the tunnel's pairing port, and use its new code. If connection times out, confirm the laptop can reach the phone over Wi-Fi; guest Wi-Fi/client isolation or a VPN that blocks local LAN access can prevent this. If SSH reports that the port forward failed, check that an older tunnel is not already using `15555`/`15556` and that remote TCP forwarding is allowed.

After stopping the debug session, run `adb disconnect 127.0.0.1:15555` on the VPS and stop the laptop tunnel with Ctrl+C. Disable Wireless debugging on the phone when finished.

## Wireless debugging directly over WireGuard

WireGuard on the **laptop alone** does not make the phone's Wi-Fi address reachable from the VPS. Use the SSH tunnel above over that VPN connection; it needs no LAN routing changes.

If the **phone itself** is a WireGuard peer, direct ADB is an alternative when its Wireless debugging ports are reachable from the VPS through the VPN. Wi-Fi must still remain enabled for Wireless debugging. Use the phone's VPN address with the pairing/connection ports shown on its screen; routes, peer AllowedIPs, and firewall rules must permit that traffic.

For example, with phone VPN address `10.77.77.2` and the example ports above, run on the VPS:

```sh
adb pair 10.77.77.2:37111
adb connect 10.77.77.2:39877
flutter devices
dart run tool/app.dart run android dev --device=10.77.77.2:39877
```

Use the actual device ID printed by `flutter devices`. For this direct connection, VS Code's regular Android preset accepts the ID in its prompt. In Zed, duplicate an Android launch preset and set the value after `-d` in `toolArgs` to that ID. The `Android via SSH tunnel` presets specifically require `127.0.0.1:15555`. A VPN connection alone does not prove that the phone's ADB ports are reachable.
