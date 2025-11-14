{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sergio-dunst;
  inherit (config.lib.colors) transparentize rice;
  colors = config.colorScheme.colors;
in
{
  options = {
    programs.sergio-dunst.enable = lib.mkEnableOption "sergio's dunst configuration";
  };

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          background = let
            charcoal-38 = transparentize colors.charcoal 0.3764705882352941;  # 38% opacity
          in
          rice.color.toRgbaHex charcoal-38;
          dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";
          origin = "top-left";
        };
        hyprvoice = let
          pale-red-38 = transparentize colors.pale-red 0.3764705882352941;  # 38% opacity, same as charcoal
        in {
          appname = "Hyprvoice";
          background = rice.color.toRgbaHex pale-red-38;
          frame_color = rice.color.toRgbHex colors.pale-red;
        };
        claude-code = let
          claude-warm-60 = transparentize colors.claude-warm-bg 0.3764705882352941;  # ~38% opacity (60 hex)
        in {
          summary = "Claude Code";
          appname = "kitty";
          background = rice.color.toRgbaHex claude-warm-60;
          frame_color = rice.color.toRgbHex colors.claude-warm-border;
        };
      };
    };
  };
}
