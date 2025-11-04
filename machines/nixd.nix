{ config, lib, pkgs, ... }:

{
  # nixd-specific Hyprland configuration
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DVI-D-1,preferred,0x0,1"
      "DVI-I-1,preferred,1920x0,1"
    ];

    input = {
      sensitivity = lib.mkForce (-0.4); # -1.0 to 1.0, negative = slower
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
}
