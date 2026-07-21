{ lib, inputs, system, ... }:

{
  programs.gtk-status-bar.monitor = "DVI-I-1";

  # nixd-specific Hyprland configuration
  wayland.windowManager.hyprland = {
    package = inputs.hyprland.packages.${system}.hyprland;
    settings = {
      monitor = [
        "DVI-D-1,preferred,0x0,1"
        "DVI-I-1,preferred,1920x0,1"
      ];

      input = {
        sensitivity = lib.mkForce (-0.4); # -1.0 to 1.0, negative = slower
      };

      # On nouveau + GTX 760 the hardware cursor disappears whenever it stops
      # moving, so render it in software instead. Desktop-only; the laptop's
      # GPU handles hardware cursors fine.
      cursor = {
        no_hardware_cursors = true;
        # Hide the cursor after 2s idle. Even with software cursors it still
        # rarely vanishes on its own; a deliberate hide makes that unnoticeable.
        inactive_timeout = 2;
      };
    };
  };

  # nixd-specific hypridle configuration - no lock, just turn off display
  services.hypridle.settings.listener = lib.mkForce [
    {
      timeout = 600; # 10 minutes
      on-timeout = "hyprctl dispatch dpms off";
      on-resume = "hyprctl dispatch dpms on";
    }
  ];

  # Stop honoring the org.freedesktop.ScreenSaver dbus inhibit protocol.
  # Firefox ("Playing audio") and OBS spam these inhibits constantly. If one
  # toggles off *after* the screen has already dpms-off'd, hypridle's onInhibit
  # tears down and recreates every idle-notification while its global isIdled
  # flag is still true (src/core/Hypridle.cpp onInhibit, v0.1.7). That discards
  # the pending "Resumed" event, so the next key/mouse input has nothing to
  # resume from and on-resume (dpms on) never runs -- the monitor stays dark
  # until you manually `hyprctl dispatch dpms on`. Ignoring the dbus inhibit
  # removes the trigger. Tradeoff: apps can no longer keep the screen awake via
  # this protocol, so a long video with no input hits the 10 min dpms timeout.
  # See reports/hypridle-dpms-wake-desync.md.
  services.hypridle.settings.general.ignore_dbus_inhibit = true;

  # nixd-specific dunst configuration - show on monitor 1 (right monitor)
  services.dunst.settings.global.monitor = 1;

  # Chromium freezes on launch on this box (GTX 760, Kepler, nouveau): the
  # GPU-compositing -> Wayland surface presentation path hangs in the
  # EGL/dmabuf buffer hand-off. Tested: any GPU-accelerated backend freezes
  # (Graphite/Vulkan, Ganesh GL, ANGLE-GL); only software present survives.
  # --disable-gpu-compositing keeps native Wayland + GPU rasterization and
  # composites in software, which avoids the hang without dropping to a full
  # --disable-gpu. Desktop-only; the laptop GPU does not have this issue.
  programs.chromium.commandLineArgs = [ "--disable-gpu-compositing" ];
}
