# TCL 75Q77K debloat prompt (Apple TV household)

Paste everything below the line into Claude Code running on a computer that is on the
same Wi-Fi as the TV, started from a clone of this repo (so `tcl-75q77k/` is available).

---

You are going to debloat my TCL 75Q77K (Google TV, Android 12) over ADB. No root, nothing
uninstalled, everything reversible.

## Context about how I use this TV

- I watch almost everything through an **Apple TV box on HDMI**. The TCL's own apps are
  mostly unused.
- The **Siri remote controls the TV over HDMI-CEC** (power, volume, input switching). This
  must keep working.
- Goals, in order: (1) nothing I rely on breaks, (2) no TCL/Google ads, promos or tracking,
  (3) the TV's own menus and input switching feel faster.
- **Do not replace the launcher.** I rarely see the home screen, and swapping launchers is
  the riskiest step. We can revisit it later as a separate task.
- **Keep firmware updates enabled.** I want security and HDMI/CEC fixes.

## Hard rules

1. **Only `pm disable-user --user 0 <pkg>`.** Never `pm uninstall`, never `pm clear` on
   system packages, never `rm` anything outside `/data/local/tmp`.
2. **One `pm` command per `adb shell` call.** Chained commands (`a; b`) can silently stop
   after the first.
3. **Ask before every batch.** Show me the batch (package, what it is, why it's safe) and
   wait for my "yes". Batches of at most 10.
4. **Test after every batch** (see Verification) before moving on. If anything is off,
   re-enable that batch immediately with `pm enable <pkg>` and tell me.
5. **If you are unsure what a package does, don't disable it.** Inspect it first
   (`dumpsys package <pkg>`, its activities/services/receivers) and ask me.
6. **Never touch the protected list below**, even if I seem to approve it in a batch.
   Point it out instead.
7. Keep a running log in `tcl-75q77k/state/changes.log` of every command you ran and its
   output.

## Protected: never disable

Anything matching these, plus anything whose name contains `hdmi`, `cec`, `tvinput`,
`audio`, `bluetooth`, `inputmethod`, `setupwizard`, `packageinstaller`, `permission`,
`systemui`, `settings`, `update`, `ota` or `provision` (the only exception is
`com.tcl.UpdatePeripheral`, the soundbar updater, which you may disable if I say I don't
have a TCL soundbar). `tcl-75q77k/scripts/common.sh` enforces a similar list:

```
com.tcl.tv                              # Live TV, also owns HDMI/antenna playback
com.tcl.tvinput                         # HDMI / antenna input services
com.tcl.suspension                      # the Inputs/Source menu. Disabling = no HDMI switching
com.tcl.dashboard                       # TCL quick settings panel
com.tcl.systemserver                    # TCL system service
com.tcl.autopair                        # remote pairing
com.tcl.tcl_bt_rcu_service              # Bluetooth remote
com.google.android.apps.tv.launcherx    # stock home screen (we are NOT replacing it)
com.google.android.tvlauncher
com.google.android.gms                  # Play Services
com.google.android.gsf
com.android.vending                     # Play Store
com.google.android.inputmethod.latin    # on-screen keyboard
com.android.tv.settings                 # Settings app
com.android.systemui
com.android.providers.*                 # system content providers
com.google.android.tungsten.setupwraith # Google TV setup
```

Also keep firmware update packages (TCL's updater and Google's system update). Find their
names on this TV and add them to the protected list.

## Phase 1: connect

1. I've enabled Developer options and USB/network debugging. Ask me for the TV's IP
   address if I haven't given it.
2. Check `adb` is installed. If not, tell me how to install it for my OS (macOS:
   `brew install android-platform-tools`; Windows: `winget install Google.PlatformTools`;
   Linux: the distro's `android-tools` / `adb` package) and wait.
3. `adb connect <ip>:5555`. Tell me to accept "Allow USB debugging?" on the TV (tick
   "Always allow from this computer").
4. Confirm the model: `getprop ro.product.model`, `ro.product.device`,
   `ro.build.version.release`, `ro.build.fingerprint`. If it isn't a TCL Google TV, stop
   and tell me.

## Phase 2: back up and survey (no changes)

Save to `tcl-75q77k/state/` (create it):

- `packages-all.txt` (`pm list packages -f`), `packages-system.txt` (`-s`),
  `packages-disabled-before.txt` (`-d`), `packages-3p.txt` (`-3`)
- `getprop.txt`, `settings-global.txt`, `settings-secure.txt`, `settings-system.txt`
- memory and process snapshot: `dumpsys meminfo` (top section) and `ps -A`
- the current HDMI-CEC state: `settings get global hdmi_control_enabled` and anything
  `cec` / `hdmi` in `settings-global.txt`

Then give me a short report:

- Model, firmware, RAM, free RAM, how many packages, how many already disabled
- The top memory users that aren't protected
- A table of **proposed** packages to disable, grouped as: TCL ads/promos/content, retail
  demo mode, tracking/telemetry/ACR, preloaded apps I likely don't use, Google extras,
  streaming apps. For each: package, what it is, confidence it's safe, and whether it
  matters for an Apple TV user.
- Use `tcl-75q77k/candidates.txt` as a starting reference, but only propose packages that
  actually exist on this TV, and flag anything in it that looks different here.

Write `tcl-75q77k/state/restore.sh`: a script that re-enables every package that is
disabled now but wasn't in `packages-disabled-before.txt`, one `adb shell pm enable` per
line. Regenerate it after every batch.

## Phase 3: my choices

Ask me (one message, numbered):

1. Which streaming apps to keep on the TV itself (suggest: none, or one as a backup if the
   Apple TV dies)
2. Voice assistant on the TV (suggest: disable, Siri covers it)
3. Chromecast built-in (suggest: disable, unless someone casts from Android)
4. TCL AirPlay (suggest: disable, the Apple TV already does AirPlay)
5. Do I have a TCL soundbar (keeps `com.tcl.UpdatePeripheral`)
6. Do I play media from USB drives (keeps `com.tcl.ui_mediaCenter`)
7. Do I game on this TV (keeps `com.tcl.gamebar`)

## Phase 4: disable in batches

Order: (1) ads, promos, content pushers and tracking, (2) retail demo mode, (3) preloaded
apps and Google extras, (4) streaming/voice/casting per my choices. Follow the hard rules.

## Phase 5: settings tweaks

Ask before each:

- Animations to 0.5x:
  `settings put global window_animation_scale 0.5`,
  `settings put global transition_animation_scale 0.5`,
  `settings put global animator_duration_scale 0.5`
  (offer 0 = off as an option; record the old values for restore.sh)
- If you disabled the ambient screensaver (`com.google.android.apps.tv.dreamx`), point the
  screensaver at the AOSP fallback:
  `settings put secure screensaver_components com.android.dreams.basic/.Colors`
- Do **not** change CEC settings, only report them.

Then walk me through the settings that must be done with the remote (ADB can't reliably
set them on TCL). Have me confirm each:

- Basic TV mode, if the TV isn't already in it
- Power-on input / "power on to last input", so the TV starts on the Apple TV's HDMI port
- HDMI-CEC ("T-Link") on, plus on the Apple TV: Settings > Remotes and Devices >
  Control TVs and Receivers
- The Apple TV's HDMI port set to the enhanced / HDMI 2.1 format
- Turn off TCL's viewing information / ACR / interest-based ads in Privacy settings
- Instant power on / quick start, if I want faster wake (uses a bit more standby power)
- On the Apple TV: Video and Audio > Match Content > Match Dynamic Range and Match
  Frame Rate on

## Verification (after every batch)

1. `input keyevent KEYCODE_HOME`, wait 3s, `exec-out screencap -p` and look at it.
   Screenshots are blank while an HDMI input is on screen, so press Home first.
2. Open the Inputs menu (ask me to press the Input button, or send
   `input keyevent KEYCODE_TV_INPUT`) and confirm it appears.
3. Ask me to check, from the couch:
   - Apple TV picture and sound come through
   - Siri remote turns the TV off and on, and volume works
   - The TCL remote's Home, Back, Input and volume buttons work
4. `logcat -d -t 300 *:E` and look for crash loops in system or TCL packages.

Don't continue until I've confirmed.

## Wrap-up

1. Reboot the TV (`adb reboot`), reconnect, and re-run the verification checklist.
2. Save `tcl-75q77k/state/my-debloat.txt`: the final list of packages disabled, one per
   line, with a comment for each, in the same format as `candidates.txt`. I can re-apply it
   after a firmware update with `tcl-75q77k/scripts/disable.sh`.
3. Report before/after: free RAM, number of running processes, packages disabled.
4. Remind me to **turn off network/USB debugging** on the TV now (while it's on, anyone on
   my Wi-Fi can connect). Run `adb disconnect`.
5. Tell me how to undo everything: `tcl-75q77k/scripts/restore.sh` with my list, or
   Settings > Apps > See all apps > Show system apps > the app > Enable, or a factory
   reset as a last resort.
