{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sergio-alacritty;
  inherit (config.lib.colors) transparentize rice intToFloat;
  colors = config.colorScheme.colors;
  colorsRgbHex = config.colorScheme.colorsRgbHex;
in
{
  options = {
    programs.sergio-alacritty.enable = lib.mkEnableOption "sergio's alacritty configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = let
        strColors = colorsRgbHex;
        bg-80 = transparentize colors.bg 0.8;  # 80% opacity
      in {
        window.opacity = (intToFloat bg-80.a) / 255.0;
        colors = {
          primary = {
            background = strColors.bg;
            foreground = strColors.fg;
          };
          normal = {
            red     = strColors.red;
            green   = strColors.green;
            yellow  = strColors.yellow;
            blue    = strColors.blue;
            magenta = strColors.magenta;
            cyan    = strColors.cyan;
            white   = strColors.fg-dark;
          };
          bright = {
            red     = strColors.bright-red;
            green   = strColors.bright-green;
            yellow  = strColors.bright-yellow;
            blue    = strColors.bright-blue;
            magenta = strColors.bright-magenta;
            cyan    = strColors.bright-cyan;
            white   = strColors.fg;
          };
          indexed_colors = [
            # where do they apply?
            { index = 16; color = strColors.orange; }
            { index = 17; color = strColors.red1; }
          ];
        };
      };
    };
  };
}
