{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sergio-zathura;
  inherit (config.lib.colors) transparentize colorToRgbaStr;
  colors = config.colorScheme.colors;
in
{
  options = {
    programs.sergio-zathura.enable = lib.mkEnableOption "sergio's zathura configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      options = let
        rgba = colorToRgbaStr;
        bg-80 = transparentize colors.bg 0.8;  # 80% opacity
        highlight-60 = transparentize colors.highlight 0.6;  # 60% opacity
        highlight-active-60 = transparentize colors.highlight-active 0.6;  # 60% opacity
      in {
        selection-clipboard = "clipboard";
        statusbar-home-tilde = true;
        window-title-basename = true;
        default-bg = rgba bg-80;
        statusbar-bg = rgba colors.bg2;
        statusbar-fg = rgba colors.electric-blue;
        # bug: no alpha support on the inputbar-bg
        inputbar-bg = rgba bg-80;
        inputbar-fg = rgba colors.electric-blue2;
        notification-error-bg = rgba bg-80;
        notification-warning-bg = rgba bg-80;
        notification-bg = rgba bg-80;
        notification-error-fg = rgba colors.red2;
        notification-warning-fg = rgba colors.yellow2;
        notification-fg = rgba colors.electric-blue2;
        highlight-active-color = rgba highlight-active-60;
        highlight-color = rgba highlight-60;
        completion-bg = rgba colors.bg2;
        completion-fg = rgba colors.fg2;
        completion-highlight-bg = rgba highlight-60;
        completion-highlight-fg = rgba colors.cyan2;
        recolor-lightcolor = "rgba(0,0,0,0)";
        recolor-keephue = true;
        recolor = true;
      };
      mappings = {
        i = "recolor";
      };
    };
  };
}
