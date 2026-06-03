# Developing

This is the contributor / hacker guide. For end-user info, see
[README.md](README.md).

## Prerequisites

- macOS or Linux
- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) installed
  via the SDK Manager (the helpers below pick up whatever version `current-sdk.cfg`
  points to)
- A Garmin developer key at `./developer_key` (used to sign builds). It's
  `.gitignore`'d and must never be committed — losing it means you can't
  publish updates to the app in the Connect IQ Store.

## Build

```sh
./build.sh            # builds for fenix6s -> sauna/bin/sauna.prg
./build.sh fenix7     # or any product id from sauna/manifest.xml
```

## Run in the simulator

```sh
./run.sh              # builds, launches the simulator, loads the app
```

In the simulator, use the on-screen buttons (or the arrow keys) for
START / DOWN / BACK.

## Sideload onto a real watch

Plug the watch in by USB (the `GARMIN` drive should mount), then:

```sh
./install.sh             # builds for fenix6s, copies to the watch
EJECT=1 ./install.sh     # …and ejects afterwards so you can unplug immediately
```

`install.sh` finds the watch's `GARMIN/Apps` folder automatically, copies
the signed `.prg`, and skips macOS's `._SAUNA.PRG` resource-fork sidecar.

By hand: `./build.sh fenix6s` then
`cp sauna/bin/sauna.prg /Volumes/GARMIN/GARMIN/Apps/SAUNA.PRG`, eject,
unplug. The app appears in the watch's activity list (press START from the
watch face).

## Project layout

```
sauna/
  manifest.xml                  app id, type, targets, permissions
                                  (Fit, FitContributor, Sensor, SensorHistory)
  monkey.jungle                 build config
  source/
    saunaApp.mc                 AppBase; wires up the activity + saves on exit
    saunaView.mc                main dashboard (custom drawn, 1s refresh)
    saunaDelegate.mc            button handling
    StopMenuDelegate.mc         finish menu (Resume / Save / Discard)
    SettingsMenuDelegate.mc     Settings menu (long-press MENU when idle)
    AboutView.mc                About screen — app name, version, GitHub QR
    SaunaActivity.mc            ActivityRecording wrapper:
                                  state, phases, temperature
  resources/
    drawables/                  launcher icon + GitHub QR PNG
    strings/                    AppName, AppVersion, menu labels
```

## CI

`.github/workflows/build.yml` builds the store `.iq` on every push, PR, and
manual dispatch and uploads it as a workflow artifact. On a `v*` tag push it
additionally creates a **draft GitHub release** with the `.iq` attached and
auto-generated release notes — so it works even with immutable releases
turned on. Every action is pinned to a commit SHA; Dependabot keeps those
SHAs fresh weekly with a 7-day cooldown.

The Connect IQ SDK + Devices + Fonts (the device data is auth-gated on
Garmin's side) is mirrored as one tarball release asset on the private
[`sv-garmin/toolbox`](https://github.com/sv-garmin/toolbox) repo. CI fetches
that tarball and extracts it to `~/.Garmin/ConnectIQ/`. Required repo secrets:

| Secret | Value |
|---|---|
| `TOOLBOX_TOKEN` | fine-grained PAT with **Contents: Read** + **Metadata: Read** on `sv-garmin/toolbox` |
| `GARMIN_DEV_KEY_BASE64` | `base64 -i developer_key` |

## Cutting a release

1. Bump the version in **three** places (until Connect IQ exposes the
   manifest version at runtime):
   - `sauna/manifest.xml` — the `version` attribute on `<iq:application>`
   - `sauna/resources/strings/strings.xml` — the `AppVersion` string
     (displayed by the About screen)
   - `CHANGELOG.md` — promote the `[Unreleased]` section to the new version
2. Commit + push.
3. Create a signed tag and push it:
   ```sh
   git tag -s v1.2.2 -m "Sauna Tracker v1.2.2"
   git push origin v1.2.2
   ```
4. The workflow builds the `.iq` and creates a **draft release** on GitHub.
   Review the auto-generated notes and the attached `sauna.iq`, then click
   **Publish**.
5. Upload that same `sauna.iq` to the Connect IQ Store dashboard for the
   store update.

## Bumping the SDK

The CI bundle is rebuilt by `make-bundle.sh` in the
[`sv-garmin/toolbox`](https://github.com/sv-garmin/toolbox) repo. Run it
locally, upload the resulting tarball as a release asset on `toolbox`, then
update `SDK_VERSION`, `SDK_BUILD`, `TOOLBOX_TAG`, and `BUNDLE_NAME` in this
repo's workflow.
