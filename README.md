# TCL 75Q77K debloat

Cleans up a TCL 75Q77K (Google TV) that's mostly used as a display for an Apple TV box:
removes TCL/Google ads, promos and tracking, speeds up the TV's own menus, and keeps
HDMI input switching and Siri remote control over HDMI-CEC working.

Everything uses ADB with `pm disable-user`: no root, nothing uninstalled, all reversible.
A factory reset always restores the TV to stock.

Based on [Gathin23/tv-vibehack](https://github.com/Gathin23/tv-vibehack), minus the
custom launcher, plus Apple TV-specific settings.

## What's here

| File | What it's for |
|---|---|
| [`tcl-75q77k/PROMPT.md`](tcl-75q77k/PROMPT.md) | The prompt to paste into Claude Code. It backs up, surveys, asks before every batch, and tests after each one. |
| [`tcl-75q77k/candidates.txt`](tcl-75q77k/candidates.txt) | Starting list of packages to disable. Not verified on a 75Q77K yet. |
| [`tcl-75q77k/scripts/disable.sh`](tcl-75q77k/scripts/disable.sh) | Disables every package in a list, skipping protected ones. Use it to re-apply your list after a firmware update. |
| [`tcl-75q77k/scripts/restore.sh`](tcl-75q77k/scripts/restore.sh) | Re-enables every package in a list. |

## How to run it

1. **On the TV:** Settings > System > About, click "Android TV OS build" 7 times. Then
   Settings > System > Developer options, turn on USB debugging (and network/wireless
   debugging if listed). Note the TV's IP address from its network settings.
2. **On a computer on the same Wi-Fi** (Mac, Windows or Linux): install
   [Claude Code](https://code.claude.com) and clone this repo.
3. Start Claude Code in the repo folder and paste the prompt from
   `tcl-75q77k/PROMPT.md`, along with the TV's IP address.
4. Accept "Allow USB debugging?" on the TV when it pops up.
5. Approve or reject each proposed batch. Test with the Siri remote when asked.
6. When done, **turn debugging off again** on the TV.

Claude saves backups, a log and a restore script in `tcl-75q77k/state/`. Your final list
ends up in `tcl-75q77k/state/my-debloat.txt`.

## Undo

- Everything: `tcl-75q77k/scripts/restore.sh <tv-ip> tcl-75q77k/state/my-debloat.txt`
- One app, from the TV: Settings > Apps > See all apps > Show system apps > the app > Enable
- Last resort: factory reset

## After a firmware update

Updates can re-enable some apps. Turn debugging back on and run:

```
tcl-75q77k/scripts/disable.sh <tv-ip> tcl-75q77k/state/my-debloat.txt
```

On Windows, run the scripts from Git Bash, or just ask Claude Code to do it.
