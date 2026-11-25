# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[semantic versioning](https://semver.org/) — bump `version` in
`sauna/manifest.xml` to match every release.

## [Unreleased]

### Added
- **Settings → Vibration** toggle to turn haptic feedback on or off
  (persisted across sessions; also respects the watch's system vibration
  setting).
- Temperature chart definition (`fitContributions`) so recorded temperature
  now appears as a graph in Garmin Connect.
- Live external Garmin *tempe* temperature sensor support via `Toybox.Sensor`
  (falling back to the watch's built-in thermometer history when no *tempe*
  is connected), plus live heart rate and temperature on the READY screen
  before starting a session.

### Changed
- Excluded non-watch targets (Edge bike computers and eTrex / GPSMAP
  handhelds) from the supported product list.

### Fixed
- Monochrome Instinct displays (Instinct 2 / 2S / 2X / E / 3 Solar /
  Crossover, Descent G1) now render all accents in white so low-luminance
  colors (such as the blue RELAX icon and red HR label) never disappear on
  1-bit screens, while keeping full color on AMOLED models.
- READY screen no longer displays stale timer or calorie values from a prior
  watch activity, and shows `S0 R0` until a session starts.
- About screen QR code and `"scan for source"` caption now scale/position
  dynamically so they no longer overlap or clip on small displays
  (Instinct 2S, Forerunner 55).

### Internal
- Enabled strict Monkey C type checking (`project.typecheck = 3`).
- Bumped CI Connect IQ SDK bundle to `9.3.0` and scoped workflow permissions
  to least privilege (`contents: read` for build, `contents: write` only on
  the tag release job).

## [1.2.1] — 2026-06-02

### Changed
- Repository moved to `github.com/sv-garmin/sauna-tracker`. The About
  screen's QR code is regenerated to point at the new URL.

### Internal
- GitHub Actions CI workflow builds the store `.iq` on every push/PR and,
  on a `v*` tag push, creates a draft release with the `.iq` attached.
  The SDK, device data and fonts are mirrored as a single tarball release
  asset on the private `sv-garmin/toolbox` repo (Garmin's `Devices/`
  endpoint requires login, so we host once instead of putting Garmin
  credentials in CI). Secrets needed: `TOOLBOX_TOKEN`, `GARMIN_DEV_KEY_BASE64`.
- All workflow actions pinned to commit SHAs.
- Dependabot keeps the pinned action SHAs current (weekly, 7-day cooldown).
- README is now end-user-only; building, sideloading, CI and release
  tooling moved to a new `DEVELOPING.md`.

## [1.2.0] — 2026-06-02

### Added
- **Settings → About** screen, accessible by long-pressing the MENU button
  when no session is recording. The About screen shows the app name, the
  current version, and a **scannable QR code** linking to the project's
  GitHub page. The Settings menu currently has only the About entry but
  is structured so more entries can be added later.

### Changed
- Renamed the app to **"Sauna Tracker"** (the `AppName` resource). The
  recorded activity name in Garmin Connect remains "Sauna" — matching
  Garmin's convention of naming activities by what they are, not by the app.

## [1.1.0] — 2026-06-01

### Added
- Support for Garmin watches with a sub-display lens (Instinct 2 / 2S / 2X
  and similar): the current mode is rendered as an icon **inside the lens**
  — ▶ for READY, a flame for SAUNA, a "Z" for RELAX, and "||" for PAUSED.
  Phase timer and total time sit to the left of the lens; heart rate,
  temperature, calories, counts and clock fill the area below.

### Fixed
- Layout on Instinct 2/2S/2X no longer clips the title and timer behind the
  sub-display lens.

## [1.0.0] — 2026-05-27

Initial release.

### Added
- Records each sauna as a Garmin **Cardio** FIT activity (no GPS) that syncs
  to Garmin Connect with duration, heart rate and calories.
- **Sauna ⇄ relax phase toggle** on the BACK button — every switch is a lap
  in the FIT, so Garmin Connect shows the duration of every phase.
- Single dashboard with: phase (SAUNA orange / RELAX blue), large current
  phase time, total session time, current heart rate, ambient temperature
  (°C or °F per device settings), calories, sauna/relax phase counts, and
  time of day.
- **Temperature recorded as a custom FIT field** via `FitContributor`, sampled
  once per second from `SensorHistory` (built-in altimeter or external *tempe*).
- **Finish menu** (Resume / Save / Discard) via START while running, or
  long-press of the menu button.
- **Contextual BACK**: switches phase while running, resumes from pause when
  paused, exits only when idle — protects against losing data by accident.
- Haptic feedback on start, pause, phase switch and save.
- Auto-save fallback in `App.onStop` if the app is force-closed while a
  session is open.
- Custom sauna-themed launcher icon.
- `build.sh`, `run.sh`, `install.sh` for one-step build / simulator / sideload.
