{ config, lib, pkgs, inputs, system, ... }:
let
  cfg = config.programs.sergio-xremap;
  launcher = import ./rofi-launcher.nix { inherit pkgs lib inputs system; };
in {
  imports = [];
  options = {
    programs.sergio-xremap.enable = lib.mkEnableOption "sergio's xremap configuration";
  };
  config = lib.mkIf cfg.enable {
    services.xremap = {
      # yes, you as per a gh issue, one should use this
      # instead of withHypr
      withWlroots = true;
      config = {
        keypress_delay_ms = 20;
        modmap = [
          {
            name = "main modmaps";
            remap = {
              shift_r = "alt_l";
            };
          }
        ];
        keymap = [
          {
            name = "main remaps";
            remap = {
              # rofi-entry skip reason=submap
              super-m = {
                remap = {
                  # rofi-entry include category=Applications icon=kitty color=#7AA2F7
                  super-l = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.kitty}/bin/kitty"
                    ];
                  };
                  # rofi-entry include category=Applications icon=firefox color=#7AA2F7
                  super-f = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.firefox}/bin/firefox"
                    ];
                  };
                  # rofi-entry include category=Utilities icon=system-file-manager color=#7DCFFF
                  super-e = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.kitty}/bin/kitty"
                      "${pkgs.ranger}/bin/ranger"
                    ];
                  };
                  # rofi-entry include category=Monitoring icon=utilities-system-monitor color=#9ECE6A
                  super-o = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.kitty}/bin/kitty"
                      "${pkgs.btop}/bin/btop"
                    ];
                  };
                  # rofi-entry include category=Applications icon=system-search color=#7AA2F7
                  super-m = {
                    launch = [
                      # bug: hyprctl does not work with commands containing semicolons
                      # Do not use "${pkgs.uwsm}/bin/uwsm" "app" "--" it makes
                      # this slow but we need this to be really fast
                      "${pkgs.rofi}/bin/rofi" "-show" "drun"
                       "-theme-str" "window {width: 20%;}"
                    ];
                  };
                  # rofi-entry include category=Utilities icon=view-grid-symbolic color=#7DCFFF
                  super-k = {
                    launch = [
                      "${inputs.rofi-switch-rust.packages.${system}.default}/bin/quick-start"
                    ];
                  };
                  # rofi-entry include category=Applications icon=bitwarden color=#7AA2F7
                  super-i = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.bitwarden-desktop}/bin/bitwarden"
                    ];
                  };
                };
              };
              # rofi-entry skip reason=submap
              super-s = {
                remap = {
                  # rofi-entry include category=Utilities icon=accessories-screenshot color=#7DCFFF
                  super-e = {
                    launch = [
                      "${pkgs.bash}/bin/sh" "-c"
                      ''
                        ${pkgs.wl-clipboard}/bin/wl-paste --type image/png |
                        ${pkgs.swappy}/bin/swappy -f -
                      ''
                    ];
                  };
                  # rofi-entry include category=Utilities icon=accessories-screenshot color=#7DCFFF
                  super-d = {
                    launch = [
                      "${pkgs.bash}/bin/sh" "-c"
                      ''
                        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -w 0)" - |
                        ${pkgs.swappy}/bin/swappy -f -
                      ''
                    ];
                  };
                };
              };
              # rofi-entry skip reason=submap
              super-u = {
                remap = {
                  # rofi-entry include category=Notifications icon=notification-history color=#F7768E
                  super-f = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "history-pop" ];
                  };
                  # rofi-entry include category=Notifications icon=notification-dismiss color=#F7768E
                  super-d = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "close" ];
                  };
                  # rofi-entry include category=Notifications icon=notification-clear-all color=#F7768E
                  super-s = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "close-all" ];
                  };
                  # rofi-entry include category=Notifications icon=notification-message color=#F7768E
                  super-c = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "action" ];
                  };
                  # rofi-entry include category=Notifications icon=notification-settings color=#F7768E
                  super-e = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "context" ];
                  };
                  # rofi-entry include category=Notifications icon=notification-status color=#F7768E
                  super-t = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "set-paused" "toggle" ];
                  };
                  # rofi-entry include category=Notifications icon=notification-paused color=#F7768E
                  super-i = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "set-paused" "true" ];
                  };
                  # rofi-entry include category=Notifications icon=notification-symbolic color=#F7768E
                  super-o = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "set-paused" "false" ];
                  };
                };
              };
              # rofi-entry skip reason=workspace-switch
              super-f = {
                remap = {
                  # rofi-entry skip reason=workspace-switch
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "1"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-i = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "2"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-o = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "3"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "4"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "5"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "6"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-l = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "7"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-semicolon = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "8"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-m = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "9"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "10"];
                  };
                };
              };
              # rofi-entry skip reason=workspace-move
              super-e = {
                remap = {
                  # rofi-entry skip reason=workspace-move
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "1"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-i = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "2"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-o = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "3"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "4"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "5"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "6"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-l = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "7"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-semicolon = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "8"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-m = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "9"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "10"];
                  };
                };
              };
              # rofi-entry skip reason=workspace-move
              super-v = {
                remap = {
                  # rofi-entry skip reason=workspace-move
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "1"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-i = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "2"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-o = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "3"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "4"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "5"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "6"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-l = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "7"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-semicolon = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "8"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-m = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "9"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "10"];
                  };
                };
              };

              # rofi-entry skip reason=submap
              super-d = {
                remap = {
                  # rofi-entry include category=Window icon=window-close color=#BB9AF7
                  super-c = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "killactive" ];
                  };
                  # rofi-entry include category=Window icon=view-restore color=#BB9AF7
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "swapnext" ];
                  };
                  # rofi-entry include category=Window icon=view-restore color=#BB9AF7
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "swapnext" "prev" ];
                  };
                  # rofi-entry include category=Window icon=view-dual color=#BB9AF7
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "togglefloating" ];
                  };
                  # rofi-entry include category=Window icon=view-fullscreen color=#BB9AF7
                  super-f = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "fullscreen" ];
                  };
                  # rofi-entry include category=Window icon=view-fullscreen-symbolic color=#BB9AF7
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "fullscreenstate" "1" ];
                  };
                  # rofi-entry include category=Window icon=window-duplicate color=#BB9AF7
                  super-m = {
                    launch = [
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movewindow" "mon:+1"
                    ];
                  };
                  # rofi-entry include category=Window icon=workspace-switcher color=#BB9AF7
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "swapactiveworkspaces" "0" "1" ];
                  };
                  # rofi-entry include category=Window icon=view-split-left-right color=#BB9AF7
                  super-t = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "layoutmsg" "togglesplit" ];
                  };
                  # rofi-entry include category=Window icon=dialog-information color=#BB9AF7
                  super-g = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "focusurgentorlast" ];
                  };
                  # rofi-entry include category=Window icon=view-split-left-right color=#BB9AF7
                  super-s = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "layoutmsg" "swapsplit" ];
                  };
                };
              };

              # rofi-entry include category=Window icon=preferences-desktop-display color=#BB9AF7
              super-comma = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "focusmonitor" "+1" ];
              };

              # rofi-entry include category=Window icon=go-next color=#BB9AF7
              super-j = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "cyclenext" ];
              };
              # rofi-entry include category=Window icon=go-previous color=#BB9AF7
              super-k = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "cyclenext" "prev" ];
              };
              # rofi-entry skip reason=workspace-relative
              super-n = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "workspace" "r+1"];
              };
              # rofi-entry skip reason=workspace-relative
              super-p = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "workspace" "r-1" ];
              };
              # rofi-entry skip reason=workspace-previous
              super-semicolon = {
                # Seems this cannot be configured to work with empty workspaces
                # also
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "workspace" "previous_per_monitor" ];
              };
              # rofi-entry skip reason=submap
              super-y = {
                remap = {
                    # rofi-entry include category=Media icon=media-playback-start color=#E0AF68
                    super-s = {
                      launch = [ "${pkgs.playerctl}/bin/playerctl" "play-pause" ];
                  };
                    # rofi-entry include category=Media icon=media-playback-next color=#E0AF68
                    super-d = {
                      launch = [ "${pkgs.playerctl}/bin/playerctl" "next" ];
                  };
                    # rofi-entry include category=Media icon=media-playback-previous color=#E0AF68
                    super-f = {
                      launch = [ "${pkgs.playerctl}/bin/playerctl" "previous" ];
                  };
                    # rofi-entry include category=Audio icon=audio-volume-muted color=#2AC3DE
                    super-e = {
                      launch = [ "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@"
                                        "toggle" ];
                  };
                };
              };
              # rofi-entry include category=Audio icon=audio-volume-low color=#2AC3DE
              super-i = {
                launch = [ "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@"
                  "5%-" ];
              };
              # rofi-entry include category=Audio icon=audio-volume-high color=#2AC3DE
              super-o = {
                launch = [ "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@"
                  "5%+" ];
              };
            };
          }
      {
        name = "to normal";
        remap = {
          # rofi-entry skip reason=mode-switch
          super-space = {set_mode = "normal"; };
        };
        mode = "default";
      }
      {
        name = "to default";
        remap = {
          # rofi-entry skip reason=mode-switch
          super-space = {set_mode = "default"; };
        };
        mode = "normal";
      }
          {
            mode = "normal";
            remap = {
              # rofi-entry include category=Window icon=go-first color=#BB9AF7
              shift-h = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "-100" "0"
                ];
              };
              # rofi-entry include category=Window icon=go-down color=#BB9AF7
              shift-j = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "0" "100"
                ];
              };
              # rofi-entry include category=Window icon=go-up color=#BB9AF7
              shift-k = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "0" "-100"
                ];
              };
              # rofi-entry include category=Window icon=go-last color=#BB9AF7
              shift-l = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "100" "0"
                ];
              };
              # rofi-entry include category=Window icon=view-left-right color=#BB9AF7
              h = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "-100" "0"
                ];
              };
              # rofi-entry include category=Window icon=view-top-bottom color=#BB9AF7
              j = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "0" "100"
                ];
              };
              # rofi-entry include category=Window icon=view-top-bottom color=#BB9AF7
              k = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "0" "-100"
                ];
              };
              # rofi-entry include category=Window icon=view-left-right color=#BB9AF7
              l = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "100" "0"
                ];
              };
              # rofi-entry include category=Window icon=view-restore color=#BB9AF7
              c = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "centerwindow"
                ];
              };
              # rofi-entry include category=Brightness icon=display-brightness-high color=#E0AF68
              semicolon = {
                launch = [
                  "${pkgs.brightnessctl}/bin/brightnessctl"
                  "set"
                  "10%+"
                ];
              };
              # rofi-entry include category=Brightness icon=display-brightness-low color=#E0AF68
              comma = {
                launch = [
                  "${pkgs.lua}/bin/lua"
                  "-e"
                  ''
                    local handle = io.popen("${pkgs.brightnessctl}/bin/brightnessctl get")
                    local current = tonumber(handle:read("*a"))
                    handle:close()

                    local handle_max = io.popen("${pkgs.brightnessctl}/bin/brightnessctl max")
                    local max = tonumber(handle_max:read("*a"))
                    handle_max:close()

                    local current_percent = (current / max) * 100

                    if current_percent > 15 then
                      os.execute("${pkgs.brightnessctl}/bin/brightnessctl set 10%-")
                    elseif current_percent > 10 then
                      os.execute("${pkgs.brightnessctl}/bin/brightnessctl set 10%")
                    end
                  ''
                ];
              };
              # rofi-entry include category=Brightness icon=display-brightness-high color=#E0AF68
              "shift-semicolon" = {
                launch = [
                  "${pkgs.brightnessctl}/bin/brightnessctl"
                  "set"
                  "100%"
                ];
              };
              # rofi-entry include category=Brightness icon=display-brightness-low color=#E0AF68
              "shift-comma" = {
                launch = [
                  "${pkgs.brightnessctl}/bin/brightnessctl"
                  "set"
                  "10%"
                ];
              };
            };
          }
          {
            name = "firefox remaps";
            remap = {
              # rofi-entry skip reason=application-remap
              super-b = [ "c-l" "shift-5" "space" ];
              # rofi-entry skip reason=application-remap
              super-c = {
                remap = {
                  # rofi-entry skip reason=application-remap
                  super-c = "c-alt-z";
                  # rofi-entry skip reason=application-remap
                  super-u = "alt-1";
                  # rofi-entry skip reason=application-remap
                  super-i = "alt-2";
                  # rofi-entry skip reason=application-remap
                  super-o = "alt-3";
                  # rofi-entry skip reason=application-remap
                  super-p = "alt-4";
                  # rofi-entry skip reason=application-remap
                  super-leftbrace =  "alt-5";
                  # rofi-entry skip reason=application-remap
                  super-j = "alt-6";
                  # rofi-entry skip reason=application-remap
                  super-k = "alt-7";
                  # rofi-entry skip reason=application-remap
                  super-l = "alt-8";
                  # rofi-entry skip reason=application-remap
                  super-semicolon = "alt-9";
                };
              };
              # TODO: move to a move
              # super-c = {
              #   remap = {
              #     super-n = "alt-right";
              #     super-p = "alt-left";
              #     super-i = "alt-down";
              #     super-o = "alt-up";
              #   };
              # };
              # rofi-entry skip reason=application-remap
              super-z = "c-shift-tab";
              # rofi-entry skip reason=application-remap
              super-x = "c-tab";
            };
            application = {
              "only" = "firefox";
            };
          }
        ];
      };
    };

    home.packages = [ launcher.script ];

  };
}
