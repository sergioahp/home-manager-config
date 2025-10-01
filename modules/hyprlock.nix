{ config, lib, pkgs, ... }:
let
  cfg = config.programs.sergio-hyprlock;
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
          color = "rgba(25, 20, 20, 1.0)";
          blur_passes = 3;
          blur_size = 8;
        }];
        
        input-field = [{
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "<span foreground=\"##cad3f5\">Password...</span>";
          shadow_passes = 2;
        }];
        
        label = [
          {
            monitor = "";
            text = "Hi $USER";
            color = "rgba(200, 200, 200, 1.0)";
            font_size = 55;
            font_family = "DejaVu Sans Mono";
            position = "0, 160";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = "$TIME";
            color = "rgba(200, 200, 200, 1.0)";
            font_size = 90;
            font_family = "DejaVu Sans Mono";
            position = "0, 230";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}