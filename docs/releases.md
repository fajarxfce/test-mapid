# GitHub releases

The release workflow builds the production flavor for Android, iOS, and Web.
All checks and platform builds must pass before a GitHub Release is created.

| Download | Purpose |
| --- | --- |
| Android APK | Install directly on Android; signed with the persistent project release key. |
| Android AAB | Store submission bundle; not directly installable. |
| iOS unsigned app ZIP | iPhone device build. Requires Apple signing and provisioning before installation; not an installable IPA or simulator build. |
| Web ZIP | Extract to the root of an HTTPS static host. Supports desktop browsers. |
| SHA256SUMS | Checksums for all four build artifacts. |

MapLibre GL supports Android, iOS, and Web. Native Windows, macOS, and Linux
applications are not included. Browser location requires HTTPS or localhost and
user permission. This workflow packages Web; it does not deploy a website.

## Create a draft

In GitHub, open **Actions → Release MAPID Explorer → Run workflow**:

1. Select the intended source branch.
2. Enter a tag such as `v1.0.0` matching the app version in
   `apps/fluent_starter/pubspec.yaml`.
3. Leave **Publish the release** unchecked.

The resulting draft contains all platform artifacts. Open **Releases** to review
and publish it. Using the CLI:

```sh
gh workflow run release.yml -f tag=v1.0.0 -f publish=false
gh run list --workflow release.yml
# After the workflow succeeds, publish the prepared draft:
gh release edit v1.0.0 --draft=false
```

Drafts are visible to repository maintainers. Published release artifacts are
not overwritten. A draft can be rebuilt only from the same source commit.
Publishing a draft can also emit a tag-push event; the workflow detects an
existing published release and skips the duplicate build.

## Release by pushing a tag

Update the app version first, commit it, then push a matching version tag.
For example, the next version after 1.0.0:

```sh
# Set apps/fluent_starter/pubspec.yaml to version: 1.0.1+2
git add apps/fluent_starter/pubspec.yaml
git commit -m "chore(release): prepare 1.0.1"
git push origin main
git tag -a v1.0.1 -m "MAPID Explorer 1.0.1"
git push origin v1.0.1
```

A tag push automatically publishes the release after every artifact is uploaded.
Tags such as `v1.0.1-rc.1` are marked as prereleases; the app version remains
`1.0.1`. Build numbers come from the release workflow run number. Keep this
workflow's run numbering continuous when distributing subsequent updates.

## Repository secrets

Configure these under **Settings → Secrets and variables → Actions**:

| Secret | Value |
| --- | --- |
| `MAPID_ENV` | Complete .env content with MAPID_API_KEY, MAPID_LAYER_ID, and MAPID_PROJECT_ID. |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded release keystore, without line breaks. |
| `ANDROID_STORE_PASSWORD` | Keystore password. |
| `ANDROID_KEY_ALIAS` | Signing key alias. |
| `ANDROID_KEY_PASSWORD` | Signing key password. |

For example, `gh secret set MAPID_ENV < .env` uploads the local configuration
without committing it. Environment values are embedded in the compiled app.
Missing configuration or signing secrets fail the release build.

The configured Android signing backup is stored outside the repository at
`~/.local/share/test-mapid/signing/`. Keep `release.jks` and `signing.json` together
in a secure backup. Reuse the same key for future updates.

Local builds can use `apps/fluent_starter/android/key.properties` with
`storeFile`, `storePassword`, `keyAlias`, and `keyPassword`. Without that file,
local case-study builds retain debug signing. GitHub releases always require the
persistent release key. The production application ID is
`io.github.fajarxfce.testmapid`, separate from dev and staging installations.

## iOS signing

No Apple signing credentials are configured. The macOS runner builds with
`--no-codesign` and explicitly labels the download as unsigned. To distribute an
installable iOS app later, configure an Apple Developer team, a signing
certificate, a matching provisioning profile, and an export method appropriate
for the intended distribution. The current workflow does not upload to TestFlight
or the App Store.

## Verified release pipeline

The first [release workflow run](https://github.com/fajarxfce/test-mapid/actions/runs/36237835244)
completed on 26 September 2026 for source `646d49e`. Generated-code checks,
static analysis, architecture/dependency checks, and all 243 tests passed.
Android, iOS, and Web artifacts were built and subsequently published as
[v1.0.0](https://github.com/fajarxfce/test-mapid/releases/tag/v1.0.0).

- The downloaded APK uses the production application ID and version `1.0.0+1`.
  Its signing certificate matches the persistent project key. The AAB signature
  and archive structure were also verified.
- The iOS archive contains an ARM64 iPhoneOS application with the production
  bundle ID, version `1.0.0+1`, and Flutter frameworks. Application signing and a
  provisioning profile are absent as intended. It has not been run on an iPhone.
- The Web build loaded Liberty and all 10 tourism features in Chromium. Feature
  selection displayed the BBY name/address, the popup dismissed, and the location
  action recentered on an emulated browser position without page errors. The
  GitHub artifact's main JavaScript matches the locally tested build.
- All four downloaded artifacts match the release's `SHA256SUMS`.
