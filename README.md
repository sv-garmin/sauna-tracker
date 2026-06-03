# Sauna Tracker

A Garmin Connect IQ watch app that records sauna sessions as a regular Garmin
activity. Tracks **elapsed time, heart rate, calories and temperature**,
alternates between **sauna** and **relax** phases, and saves each session
to **Garmin Connect**. No GPS / location is used.

> **Temperature note:** the value comes from the watch's built-in thermometer.
> Worn on the wrist it reads close to body temperature, not true sauna air
> temperature, and a sauna's heat can exceed the watch's rated operating
> range. An external Garmin *tempe* sensor gives an accurate ambient reading.

## Install

Open **Garmin Connect Mobile** on your phone, browse the Connect IQ Store,
search for **Sauna Tracker**, and tap *Install*. The app syncs to your watch
on the next sync and appears in the activity list.

## On-watch controls (Fenix / Epix)

| Button                | Action                                                  |
|-----------------------|---------------------------------------------------------|
| START (top-right)     | Start; press again to pause + open the finish menu      |
| BACK (bottom-right)   | Switch sauna ⇄ relax while running; resume from pause; exits when idle |
| MENU (long-press UP)  | Open the finish menu (Resume / Save / Discard)          |

A session starts in the **sauna** phase; each BACK press ends the current
phase and starts the other one (recorded as a new lap). The finish menu
offers **Resume / Save / Discard**. Saving writes the activity to your
watch's history, which syncs to Garmin Connect.

## Single dashboard

Everything is shown on one screen, no paging:

```
        SAUNA          phase / status (orange = sauna, blue = relax)
        3:01           time in the current phase (big)
      total 12:34      total elapsed time
  HR 132      78°C     heart rate | temperature
  84 kcal     S2 R1    calories   | sauna/relax counts
       14:35           time of day
```

## More

- [Changelog](CHANGELOG.md)
- [Development guide](DEVELOPING.md) — building from source, sideloading, releasing
- Licensed under the [MIT License](LICENSE)
