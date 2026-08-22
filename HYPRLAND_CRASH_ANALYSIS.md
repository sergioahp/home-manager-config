# Hyprland Crash Analysis
**Date:** 2025-11-16 21:34 (approximately)
**System:** NixOS 25.11 (Xantusia)
**GPU:** NVIDIA GeForce GTX 760 (GK104)
**Driver:** Open source (Nouveau)

Very funny claude, you are often overconfident in your own work and overstate,
the proper solution was a rollback, you took this as _this isn't going to work_
while the the previous version just does, you suggested the proprietary
driviers, working with you often feels like fighting reviewer 2 so I conceded
and we spent a while trying to make the proprietary drivers work, these files
often contaminate your context, making new sessions and compacted sessions snap
back to the same failure mode and conclusssion (this is where usability dies)
see below, you went overconfident on a path you came out with and we haven't
tested instead of the one that was just working.

Why do new claude sessions need to have this at the root of the repo? they all
get contaminated and have to re-inspect the wayland situation and need help to
get out of the loop.

## Summary
Hyprland compositor crashed during startup, causing the session to fail and dropping the user to TTY. The crash was triggered by the SDDM display manager helper during Wayland session initialization.

## Key Findings

### 1. Primary Error
```
Nov 16 02:08:46 nixd sddm[1119]: Auth: sddm-helper crashed (exit code 1)
Command: uwsm start -S -F /run/current-system/sw/bin/Hyprland --user admin
```

The SDDM helper process crashed with exit code 1 while attempting to start the Hyprland session via `uwsm` (Universal Wayland Session Manager).

### 2. Wayland Communication Failure
```
Nov 16 02:08:46 nixd uwsm_Hyprland[2064]: (EE) failed to read Wayland events: Broken pipe
```

This indicates a catastrophic failure in the Wayland protocol communication, likely occurring when the Hyprland compositor process terminated unexpectedly.

### 3. NVIDIA GPU Detection
```
Nov 16 02:08:46 nixd uwsm_Hyprland[2033]: 07:00.0 VGA compatible controller: NVIDIA Corporation GK104 [GeForce GTX 760]
Nov 16 02:08:46 nixd uwsm_Hyprland[2033]: [WARN] Warning: you're using an NVIDIA GPU. Make sure you follow the instructions on the wiki if anything is amiss.
```

Hyprland detected the NVIDIA GPU and issued a warning. The GTX 760 (Kepler architecture, released 2013) is running on **open source Nouveau drivers**, which have known compatibility issues with modern Wayland compositors.

## Root Cause Analysis

### Most Likely Cause: Nouveau Driver Incompatibility
The open source Nouveau drivers have several limitations that can cause Hyprland to crash:

1. **Incomplete Vulkan Support**: Nouveau's Vulkan implementation (via Mesa's NVK) is still experimental and incomplete for older Kepler GPUs like the GTX 760
2. **Limited Power Management**: Nouveau cannot properly reclocking older NVIDIA GPUs, leading to performance issues and potential instability
3. **Missing Features**: Nouveau lacks support for many modern Wayland compositor features that Hyprland relies on

The GTX 760 (Kepler architecture) is particularly problematic because:
- Nouveau's NVK Vulkan driver primarily targets newer Maxwell+ architectures
- Kepler GPUs are stuck at boot clocks without proper reclocking support
- Hardware video decode/encode is limited or non-functional

### Contributing Factors

1. **Session Manager Complexity**: The crash occurred during SDDM → uwsm → Hyprland transition, adding complexity to the startup chain
2. **Wayland Protocol Issues**: The "Broken pipe" error suggests Hyprland crashed during initialization before establishing proper Wayland communication
3. **Missing Environment Variables**: No NVIDIA-specific environment variables detected in the Hyprland configuration

## Recommendations

### Immediate Solutions (Priority Order)

#### Option 1: Switch to Proprietary NVIDIA Drivers (Recommended)
The proprietary NVIDIA drivers have much better Wayland support:

```nix
# In NixOS configuration.nix or home-manager
services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  modesetting.enable = true;
  open = false;  # Use proprietary driver
};

# Required environment variables for Hyprland + NVIDIA
wayland.windowManager.hyprland.settings = {
  env = [
    "LIBVA_DRIVER_NAME,nvidia"
    "XDG_SESSION_TYPE,wayland"
    "GBM_BACKEND,nvidia-drm"
    "__GLX_VENDOR_LIBRARY_NAME,nvidia"
    "WLR_NO_HARDWARE_CURSORS,1"  # Often needed for NVIDIA
  ];
};
```

#### Option 2: Use X11 Instead of Wayland (Temporary Workaround)
Nouveau has better X11 support than Wayland:
- Switch to i3, AwesomeWM, or another X11 window manager
- Less ideal but more stable with Nouveau

#### Option 3: Disable Hardware Acceleration (Last Resort)
Force software rendering to avoid driver issues:
```nix
wayland.windowManager.hyprland.settings = {
  env = [
    "WLR_RENDERER,pixman"  # Software rendering
    "WLR_NO_HARDWARE_CURSORS,1"
  ];
};
```

### Long-term Solutions

1. **Hardware Upgrade**: Consider replacing the GTX 760 with:
   - AMD GPU (excellent open source driver support)
   - Newer NVIDIA GPU (Maxwell or newer) with proprietary drivers
   - Intel Arc GPU (good open source support)

2. **Wait for Nouveau NVK Improvements**: Monitor Mesa/Nouveau development, but Kepler support remains low priority

## Additional Debug Steps

If crashes continue after implementing recommendations:

1. **Enable Hyprland debug logging**:
   ```nix
   wayland.windowManager.hyprland.settings = {
     debug = {
       disable_logs = false;
     };
   };
   ```

2. **Check live logs during startup**:
   ```bash
   journalctl -f | grep -i "hyprland\|uwsm\|sddm"
   ```

3. **Test Hyprland from TTY**:
   ```bash
   # Start Hyprland directly without SDDM
   Hyprland
   ```

4. **Verify GPU capabilities**:
   ```bash
   glxinfo | grep -i "opengl\|vendor"
   vulkaninfo | grep -i "driver\|version"
   ```

## References
- [Hyprland NVIDIA Wiki](https://wiki.hyprland.org/Nvidia/)
- [Nouveau Feature Matrix](https://nouveau.freedesktop.org/FeatureMatrix.html)
- [Hyprland Crashes and Bugs](https://wiki.hyprland.org/Crashes-and-Bugs/)

## System Information Snapshot
- **NixOS Version**: 25.11 (Xantusia)
- **Build ID**: 25.11.20250630.3016b4b
- **Session Manager**: uwsm 0.22.0
- **Display Manager**: SDDM
- **Previous Session Runtime**: 3h 46min (before crash)
- **Memory Usage (peak)**: 9GB

## Version History (recorded 2026-07-22)

Reconstructed from `flake.lock` git history because the crashing versions were
never written down. Before the pin, Hyprland was NOT a direct flake input; it
came from nixpkgs (`programs.hyprland` / `wayland.windowManager.hyprland`
defaults), so the "unstable" version is whatever nixpkgs shipped at the locked
rev.

### Known-unstable (daily freezes/crashes, ~2026-02 to the 2026-05-14 pin)
- nixpkgs rev `0182a36` (lastModified 2026-02-17)
- **Hyprland 0.53.3**
- **mesa 26.0.0** (nouveau, GTX 760 / Kepler)

### The pin (commit 93f628c, 2026-05-14 "checkpoint: hyprland compatibility for nvidia desktop")
Bumped nixpkgs to `da5ad66` (which offered Hyprland 0.54.3 / mesa 26.1.0) but
in the same commit pinned Hyprland to the upstream flake at **v0.49.0**, built
from source. So the box jumped 0.53.3 -> 0.49.0 and never ran 0.54.3. The
source build took hours and was effectively never a viable update path.

### CRITICAL correction: mesa has been pinned at 25.1.4 the whole time

`~/nixos` `configuration.nix` sets `hardware.graphics.package =
inputs.nixpkgsGen11.legacyPackages.<sys>.mesa`, and `nixpkgsGen11` is frozen at
`3016b4b` = **mesa 25.1.4** (commit 98a4244 "Pin graphics stack to gen11 Mesa",
2026-05-12). So the GL driver actually loaded at `/run/opengl-driver` has been
**mesa 25.1.4** continuously, regardless of what the main nixpkgs ships.

Every "mesa 26.x" figure elsewhere in this doc is the main-nixpkgs DEFAULT, not
the loaded driver - EXCEPT the pre-2026-05-12 daily-freeze era, which predates
the gen11 pin and therefore did load the default (26.0.x). Net effect: across
this whole session's tests, **mesa was constant at 25.1.4 and only Hyprland
changed.** The golden-stable stack is **Hyprland 0.49.0 + mesa 25.1.4**.

### After unpin (2026-07-22, back to nixpkgs hyprland)
- system: **Hyprland 0.54.3** running on the pinned **mesa 25.1.4** (nixpkgs
  default at `da5ad66` was 26.1.0 but is not the loaded driver)
- home-manager nixpkgs `61b7c44`: Hyprland 0.55.4 (profile copy only, not launched; harmless 0.54<->0.55 skew)

## Update: brief run on 0.55.4 (2026-07-22)

Bumped `~/nixos` nixpkgs `da5ad66` -> `61b7c44`: Hyprland 0.55.4, kernel
6.18.38 (main-nixpkgs default mesa 26.1.5, but the loaded driver stayed at the
pinned mesa 25.1.4). Two issues, neither a hard failure:
- First post-update boot only: status bar + overlay took ~53s to appear.
  Root cause was a one-time cold GPU shader cache on the new mesa (nouveau/NVK
  recompiling shaders) plus cold GTK/fontconfig caches; the systemd units
  themselves started in ~4s. Subsequent boots were 10-18s. Self-resolving.
- Every session: Hyprland notification "WARNING: Hyprland is being launched
  without start-hyprland. This is highly advised against." New advisory in
  0.55: the plain `hyprland.desktop` session now runs the `start-hyprland`
  supervisor, but the UWSM session launches the bare `Hyprland` binary, so it
  warns. Cosmetic false-positive for UWSM users; no env var suppresses it
  (checked the compositor's full HYPRLAND_* list). Did NOT fix the bug codex
  reported as fixed in newer Hyprland. Reverted to `da5ad66` (0.54.3).

## Freeze on 0.54.3 (2026-07-24 ~21:00)

Full hard freeze after ~27h uptime (Thu 2026-07-23 17:49 -> Fri 2026-07-24
21:00); required a hard reboot. Running stack at the time:
- **Hyprland 0.54.3**, loaded **mesa 25.1.4** (gen11 pin), kernel 6.18.28
- nouveau, GTX 760 (GK104, Kepler)

### What the logs show
- The journal for that boot stops dead at `21:00:00`, right after a routine
  `logrotate.service` run. No shutdown sequence -> it was a hard hang, not a
  clean or dirty reboot.
- Kernel ring buffer for the whole boot: nouveau initialized cleanly at start
  (GK104, 2048 MiB GDDR5, nouveau 1.4.0) and logged NO GPU errors afterward -
  no Xid, no fifo fault, no `DRM: GPU hang`, no reset, no reclock/pstate
  message. The only kernel events all session were unrelated: a couple of USB
  device resets and one `Bluetooth: hci0: command tx timeout`.
- `journalctl -p err` for the final hour: no entries. No OOM-kill, no segfault,
  no coredump, no Hyprland crash logged.
- Last userspace activity before the stop was normal (gtk-status-bar dbus
  signals, a mongodb WiredTiger checkpoint, a successful network probe).

### Interpretation
A silent hard hang that leaves zero trace is the classic nouveau/Kepler GPU
lockup already described at the top of this document (stuck boot clocks,
incomplete Wayland/NVK support). It is not attributable to any app or to a
Hyprland crash in the logs. Because mesa was constant at 25.1.4 across all
tests, the stability difference tracks Hyprland: 0.49.0 ran for months, while
0.54.3 hung once in ~27h. (The old daily-freeze era was a different stack -
Hyprland 0.53.3 on the then-default mesa 26.0.x, before the gen11 mesa pin.)

### On mesa: nothing lower to try
mesa is already at 25.1.4, below every "26.x" figure in this doc, and it is the
one variable that did NOT change. So there is no lower-mesa move to make here;
the lever is Hyprland. Dropping mesa further has no evidence behind it and would
mean hand-pinning an even older nixpkgs for the graphics stack.

### Action (2026-07-24)
Re-pinned Hyprland to the upstream flake **v0.49.0** on both `~/nixos` and
`~/.config/home-manager` (the exact build is still in the store from before the
unpin, so no source rebuild). mesa is left at the pinned 25.1.4. Together that
reproduces the exact golden-stable stack (0.49.0 + 25.1.4). codex's bug remains
unfixed at 0.49.0, accepted for now in exchange for stability.
