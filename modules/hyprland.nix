{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.programs.sergio-hyprland;
in {
  imports = [
    ./hyprlock.nix
  ];
  options = {
    programs.sergio-hyprland.enable = lib.mkEnableOption "sergio's hyprland config";
  };
  config = lib.mkIf cfg.enable {
    # Enable hyprlock module
    programs.sergio-hyprlock.enable = true;
    
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      settings = {
        "$mod" = "SUPER";
        general = {
          workspace = [
            "1, defaultName:u"
            "2, defaultName:i"
            "3, defaultName:o"
            "4, defaultName:p"
            "5, defaultName:j"
            "6, defaultName:k"
            "7, defaultName:l"
            "8, defaultName:s"
            "9, defaultName:m"
            "10, defaultName:c"
          ];

          gaps_in = 3;
          gaps_out = 4;
          "col.active_border" = "rgba(05d0e866) rgba(450086ff) 20deg";
          "col.inactive_border" = "rgba(00000000)";
          border_size = 5;
        };
        decoration = {
          blur = {
            passes = 2;
            size = 3;
            noise = 0.055;
            # vibrancy = 0.4;
            vibrancy_darkness = 0.4;
            input_methods = true;
            input_methods_ignorealpha = 0.1;
            popups = true;
            popups_ignorealpha = 0.1;
          };
          shadow = {
            enabled = false;
            range = 15;
            render_power = 1;
            # color = "0xee6d80c9";
            color = "0x001a1a1a";
            # color_inactive = "0x001a1a1a";
          };
        };
        animations = {
          enabled = false;
        };
        dwindle = {
          preserve_split = 1;
        };
        input = {
          kb_layout = "us";
          kb_variant = "altgr-intl";
          kb_options = "caps:swapescape";
          repeat_delay = 275;
          repeat_rate = 26;
          follow_mouse = 1;
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
          touchpad = {
            natural_scroll = true;
          };
        };
        bind = [
          "$mod, Q, exec, uwsm stop"
          "$mod, F12, exec, systemctl restart --user xremap"
        ];
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        layerrule = [
          "blur, rofi"
          "blur, notifications"
          # "ignorezero, bar"
          # "blur, bar"
        ];
        misc = {
          focus_on_activate = true;
        };
        monitor=",1920x1080@60, 0x0, 1";
        exec-once = [
          "${inputs.gtk-status-bar.packages.${pkgs.system}.default}/bin/gtk-status-bar"
        ];
      };
    };
  };
}
