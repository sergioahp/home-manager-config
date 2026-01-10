{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sergio-rofi;
  inherit (config.lib.colors) transparentize colorToRgbaLiteral rice;
  colors = config.colorScheme.colors;
in
{
  options = {
    programs.sergio-rofi.enable = lib.mkEnableOption "sergio's rofi configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      extraConfig = {
        show-icons = true;
        sorting-method = "fzf";
        matching = "fuzzy";
        case-smart = true;
      };
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
        bg-60 = transparentize colors.bg 0.6;  # 60% opacity
        bg2-90 = transparentize colors.bg2 0.9;  # 90% opacity
      in {
        "*" = {
          bg = mkLiteral (colorToRgbaLiteral bg-60);
          fg0 = mkLiteral (rice.color.toRgbHex colors.magenta);
          accent-color = mkLiteral (rice.color.toRgbHex colors.accent);
          urgent-color = mkLiteral (rice.color.toRgbHex colors.urgent);
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@fg0";
          margin = 0;
          padding = 0;
          spacing = 0;
        };
        window = {
          background-color = mkLiteral "@bg";
        };
        inputbar = {
          spacing = mkLiteral "8px";
          padding = mkLiteral "8px";
          background-color = mkLiteral "@bg";
        };
        prompt = {
          text-color = mkLiteral "@accent-color";
        };
        "element selected" = {
          text-color = mkLiteral "@bg";
          background-color = mkLiteral "@accent-color";
        };
        "element normal active" = {
          text-color = mkLiteral "@accent-color";
        };
        "element selected normal, element selected active" = {
          background-color = mkLiteral "@accent-color";
          text-color = mkLiteral "@bg";
        };
        "element-text" = {
          text-color = mkLiteral "inherit";
        };
      };
    };
  };
}
