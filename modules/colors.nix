{ config, lib, pkgs, inputs, ... }:

let
  rice = inputs.nix-rice.lib.nix-rice;

  # Solid color palette (without built-in transparency)
  solidColors = rice.palette.tPalette rice.color.hexToRgba {
    bg = "#282c3c";
    charcoal = "#1f2026";
    bg2 = "#1e2030";
    fg2 = "#c8d3f5";
    highlight = "#2d3f76";
    highlight-active = "#ff966c";
    bg-dark = "#16161e";
    bg-dark1 = "#0C0E14";
    black = "#15161e";
    bg-highlight = "#292e42";
    electric-blue = "#82aaff";
    electric-blue2 = "#828bb8";
    blue = "#7aa2f7";
    blue0 = "#3d59a1";
    blue1 = "#2ac3de";
    blue2 = "#0db9d7";
    blue5 = "#89ddff";
    blue6 = "#b4f9f8";
    blue7 = "#394b70";
    bright-blue = "#8db0ff";
    comment = "#565f89";
    cyan = "#7dcfff";
    cyan2 = "#65bcff";
    bright-cyan = "#a4daff";
    dark3 = "#545c7e";
    dark5 = "#737aa2";
    fg = "#c0caf5";
    fg-dark = "#a9b1d6";
    fg-gutter = "#3b4261";
    green = "#9ece6a";
    bright-green = "#9fe044";
    green1 = "#73daca";
    green2 = "#41a6b5";
    magenta = "#bb9af7";
    magenta2 = "#ff007c";
    bright-magenta = "#c7a9ff";
    orange = "#ff9e64";
    purple = "#9d7cd8";
    red = "#f7768e";
    bright-red = "#ff899d";
    red1 = "#db4b4b";
    red2 = "#c53b53";
    teal = "#1abc9c";
    terminal-black = "#414868";
    yellow = "#e0af68";
    bright-yellow = "#faba4a";
    yellow2 = "#ffc777";
    # Additional UI colors
    pale-red = "#dca6af";
    accent = "#88C0D0";
    urgent = "#EBCB8B";
    # Lock screen colors
    lock-input-inner = "#5b6078";
    lock-input-outer = "#181926";
    lock-text = "#c8c8c8";
  };

  # Helper: convert int to float
  intToFloat = rice.float.toFloat;

  # Apply transparency multiplicatively to a color's alpha channel
  # Takes a color object and a factor (0.0-1.0) and returns a new color with adjusted alpha
  transparentize = color: factor:
    color // {
      a = builtins.floor (color.a * factor);
    };

  # Ensure integer conversion without decimals
  intStr = n: toString (builtins.floor n);

  # Convert color to rgba string for zathura (rgba format)
  colorToRgbaStr = { r, g, b, a ? 255 }:
    let
      f = pkgs.lib.strings.floatToString;
    in
    "rgba(${intStr r},${intStr g},${intStr b},${f ((intToFloat a) / 255.0)})";

  # Convert color to rgba literal string for rofi mkLiteral
  colorToRgbaLiteral = color:
    let
      f = pkgs.lib.strings.floatToString;
    in
    "rgba(${intStr color.r},${intStr color.g},${intStr color.b},${f ((intToFloat color.a) / 255.0)})";

  # Convert color to rgb() string for hyprlock
  colorToRgbStr = color:
    "rgb(${intStr color.r}, ${intStr color.g}, ${intStr color.b})";

in
{
  options = {
    colorScheme = {
      colors = lib.mkOption {
        type = lib.types.attrs;
        default = solidColors;
        description = "Color palette";
      };

      colorsRgbHex = lib.mkOption {
        type = lib.types.attrs;
        readOnly = true;
        description = "Color palette in RGB hex format (derived from colors)";
      };
    };
  };

  config = {
    # Derive colorsRgbHex from the actual colors value (stays in sync with overrides)
    colorScheme.colorsRgbHex = rice.palette.toRgbHex config.colorScheme.colors;

    # Export color utilities as lib functions for use in home.nix
    lib.colors = {
      inherit transparentize colorToRgbaStr colorToRgbaLiteral colorToRgbStr;
      inherit rice intToFloat;
    };
  };
}
