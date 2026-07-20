{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.programs.sergio-hyprland;
  legacyHyprland = lib.versionOlder config.wayland.windowManager.hyprland.package.version "0.50";
in {
  imports = [
    ./hyprlock.nix
    ./hypridle.nix
    inputs.gtk-status-bar.homeModules.default
    inputs.status-overlay.homeModules.default
  ];
  options = {
    programs.sergio-hyprland.enable = lib.mkEnableOption "sergio's hyprland config";
  };
  config = lib.mkIf cfg.enable {
    # Enable hyprlock and hypridle modules
    programs.sergio-hyprlock.enable = true;
    programs.sergio-hypridle.enable = true;
    # gtk-status-bar and status-overlay both install a unit (no Install.WantedBy);
    # we start them from exec-once below so they only run alongside Hyprland and we
    # still get journald logs + on-failure restart.
    programs.gtk-status-bar.enable = true;
    programs.status-overlay.enable = true;

    home.packages = with pkgs; [
      hyprpicker
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
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
            popups = true;
          } // lib.optionalAttrs legacyHyprland {
            input_methods_ignorealpha = 0.1;
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
        bindl = [
          ", switch:off:Lid Switch, exec, hyprctl dispatch dpms on"
        ];
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        layerrule = if legacyHyprland then [
          "blur, rofi"
          # Newer rofi renders its layer-surface fullscreen with transparent
          # margins, so without an alpha cutoff Hyprland blurs the entire
          # monitor. ignorealpha 0.1 skips painting (and thus blurring) pixels
          # below 10% alpha, confining the effect to the actual popup.
          "ignorealpha 0.1, rofi"
          "blur, notifications"
          # "ignorezero, bar"
          # "blur, bar"
          "blur, status-overlay"
          "ignorealpha 0.1, status-overlay"
        ] else [
          "blur on, match:namespace ^(rofi)$"
          # See note in legacy branch above; same reasoning, modern syntax.
          "ignore_alpha 0.1, match:namespace ^(rofi)$"
          "blur on, match:namespace ^(notifications)$"
          # "ignore_alpha 0.0, match:namespace ^(bar)$"
          # "blur on, match:namespace ^(bar)$"
          "blur on, match:namespace ^(status-overlay)$"
          "ignore_alpha 0.1, match:namespace ^(status-overlay)$"
        ];
        misc = {
          focus_on_activate = true;
        };
        exec-once = [
          # UWSM exports WAYLAND_DISPLAY etc. into the user systemd environment,
          # but HYPRLAND_INSTANCE_SIGNATURE is only known after Hyprland is up.
          # Re-import here so systemd-launched children (the status bar) can find
          # Hyprland's IPC sockets at $XDG_RUNTIME_DIR/hypr/$HIS/.socket2.sock.
          "systemctl --user import-environment HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user start gtk-status-bar.service"
          "systemctl --user start status-overlay.service"
        ];
      };
    };
  };
}
