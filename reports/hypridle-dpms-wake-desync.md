# hypridle: input fails to wake the monitor after a dbus inhibit toggles

## Symptom

On nixd the monitor turned off after the 10 minute idle timeout, and then
keyboard/mouse input did **not** turn it back on the way it normally does. The
screen only came back after manually running:

    hyprctl dispatch dpms on

This is intermittent. Most idle cycles wake on input fine; occasionally one
gets stuck dark.

## Evidence

hypridle journal (`journalctl --user -u hypridle.service`) around the event:

    01:58:27  Idled: rule 650e3dd3d950
    01:58:27  Running hyprctl dispatch dpms off
    01:58:28  ok                                    <- screen goes dark
    01:59:30  ScreenSaver inhibit: true  from firefox ("Playing audio")  locks 0->1
    01:59:43  ScreenSaver inhibit: false from firefox ("Playing audio")  locks 1->0
              ... nothing. No "Resumed", no "dpms on", ever.

The whole evening the log is full of firefox ("Playing audio") and libobs
("OBS Video/audio") screensaver inhibits toggling on and off every few seconds.
The stuck cycle is simply the one where an inhibit released just *after* the
screen had already dpms-off'd.

Note: the manual `hyprctl dispatch dpms on` that fixed it does not appear in the
hypridle log, because it was run directly, not through hypridle's on-resume.

## Root cause (confirmed from source, hypridle v0.1.7)

hypridle tracks idle state with a single global bool `isIdled`, not per
listener (`src/core/Hypridle.cpp`).

1. `onIdled()` sets `isIdled = true` and, with no inhibit locks held, runs the
   listener's `on-timeout` (`hyprctl dispatch dpms off`). Screen off.

2. A screensaver inhibit arriving later (`onInhibit(true)`) just bumps the lock
   counter. Nothing else, because the counter is now > 0.

3. When that inhibit is released (`onInhibit(false)`) and the counter returns
   to 0 **while `isIdled` is still true**, hypridle runs this block:

       if (m_iInhibitLocks == 0 && isIdled) {
           for each listener:
               l.notification->sendDestroy();
               l.notification = makeShared<...>(sendGetIdleNotification(timeout));
               // re-hook setIdled / setResumed
       }

   It destroys every idle-notification and creates fresh ones. The fresh
   notifications are not in the idled state, and `isIdled` is left `true`. The
   pending "Resumed" event that would have fired `on-resume` is gone.

4. Subsequent input has no idled notification to resume from, so `onResumed()`
   never runs and `dpms on` never fires. The monitor stays dark. (It would only
   self-heal after another full timeout idle + input cycle.)

So the physical DPMS state and hypridle's notion of idle state desync. This is
a hypridle bug, not a misconfiguration: the `on-resume` line is present and
correct.

## Fix

Set `general:ignore_dbus_inhibit = true` on nixd (`machines/nixd.nix`).

At `src/core/Hypridle.cpp` `setupDBUS()`, this flag gates the entire
registration of the `org.freedesktop.ScreenSaver` interface. With it set,
hypridle never receives the firefox/OBS inhibit messages, the lock counter
never toggles, and the destroy/recreate block in step 3 never runs. The exact
trigger is removed.

### Tradeoff

hypridle no longer honors the `org.freedesktop.ScreenSaver` app inhibit
protocol. Apps (video players, browsers in fullscreen video) can no longer keep
the screen awake through it, so a long video with no keyboard/mouse input will
hit the 10 minute dpms timeout. In practice the "Playing audio" inhibit fired
for any audio at all (including background music), so it was keeping the screen
on more often than wanted anyway.

This is scoped to nixd only. The base config and the laptop are untouched, so
if wake-on-input reliability there is fine and video-keeps-awake is wanted, no
change is needed.

Note this does **not** affect `ignore_systemd_inhibit` (systemd
`BlockInhibited`) nor the separate lock/sleep inhibitor unit in
`modules/hypridle.nix` (that one blocks `handle-lid-switch:sleep` via
systemd-inhibit and is unrelated).

## Alternatives considered

- Per-listener `ignore_inhibit = true`: does not help. The destroy/recreate
  loop in `onInhibit` iterates over *all* listeners unconditionally; the
  per-listener flag only changes the notification type and the onIdled/
  onResumed gating, not whether the notification gets torn down.
- Upstream fix: the correct fix is for hypridle to not discard idled state on
  inhibit release (or to re-fire on-resume when recreating a notification for a
  listener whose action already ran). Worth reporting upstream.
