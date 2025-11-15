{ config, lib, ... }:

let
  colors = config.colorScheme.colors;
  inherit (config.lib.colors) rice;
in
{
  options = {
    categoryColors = lib.mkOption {
      type = lib.types.attrs;
      description = "Color assignments for UI categories used across rofi launcher and other modules";
      default = {
        Applications = rice.color.toRgbHex colors.blue;
        Utilities = rice.color.toRgbHex colors.cyan;
        Monitoring = rice.color.toRgbHex colors.green;
        Notifications = rice.color.toRgbHex colors.red;
        Window = rice.color.toRgbHex colors.magenta;
        Media = rice.color.toRgbHex colors.yellow;
        Audio = rice.color.toRgbHex colors.blue1;
        Brightness = rice.color.toRgbHex colors.yellow;
        Productivity = rice.color.toRgbHex colors.blue;
      };
    };
  };
}
