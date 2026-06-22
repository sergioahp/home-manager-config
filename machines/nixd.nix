{ config, lib, pkgs, inputs, system, ... }:

{
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
