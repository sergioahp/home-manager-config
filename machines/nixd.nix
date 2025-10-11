{ config, lib, pkgs, ... }:

{
  # nixd-specific Hyprland monitor configuration
  wayland.windowManager.hyprland.settings.monitor = [
    "DVI-D-1,preferred,0x0,1"
    "DVI-I-1,preferred,1920x0,1"
  ];
}
