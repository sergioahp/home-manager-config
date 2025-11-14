{ config, lib, pkgs, ... }:
let
  cfg = config.programs.sergio-hyprlock;
  colors = config.colorScheme.colors;
  inherit (config.lib.colors) colorToRgbStr colorToRgbaStr intToFloat;

  # Convert color to rgba string (wrapper for colorToRgbaStr)
  colorToRgbaStrFull = colorToRgbaStr;
in {
  imports = [];
  options = {
    programs.sergio-hyprlock.enable = lib.mkEnableOption "sergio's hyprlock configuration";
  };
  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
        };
        
        background = [{
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }];
        
        input-field = [{
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = colorToRgbStr colors.fg2;
          inner_color = colorToRgbStr colors.lock-input-inner;
          outer_color = colorToRgbStr colors.lock-input-outer;
          outline_thickness = 5;
          placeholder_text = "<span foreground=\"#${config.colorScheme.colorsRgbHex.fg2}\">Password...</span>";
          shadow_passes = 2;
        }];
        
        label = [
          {
            monitor = "";
            text = "Hi $USER";
            color = colorToRgbaStrFull colors.lock-text;
            font_size = 55;
            font_family = "DejaVu Sans Mono";
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = "$TIME12";
            color = colorToRgbaStrFull colors.lock-text;
            font_size = 90;
            font_family = "DejaVu Sans Mono";
            position = "0, 250";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}