# Hyprland Crash Analysis
**Date:** 2025-11-16 21:34 (approximately)
**System:** NixOS 25.11 (Xantusia)
**GPU:** NVIDIA GeForce GTX 760 (GK104)
**Driver:** Open source (Nouveau)

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
