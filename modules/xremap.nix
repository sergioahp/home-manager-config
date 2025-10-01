{ config, lib, pkgs, ... }:
let
  cfg = config.programs.sergio-xremap;
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
              super-m = {
                remap = {
                  super-l = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.kitty}/bin/kitty"
                    ];
                  };
                  super-f = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.firefox}/bin/firefox"
                    ];
                  };
                  super-e = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.kitty}/bin/kitty"
                      "${pkgs.ranger}/bin/ranger"
                    ];
                  };
                  super-o = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.kitty}/bin/kitty"
                      "${pkgs.btop}/bin/btop"
                    ];
                  };
                  super-m = {
                    launch = [
                      # bug: hyprctl does not work with commands containing semicolons
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.rofi}/bin/rofi" "-show" "drun"
                       "-theme-str" "window {width: 20%;}"
                    ];
                  };
                  super-k = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.rofi}/bin/rofi" "-show" "window"
                    ];
                  };
                  super-i = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm" "app" "--"
                      "${pkgs.bitwarden}/bin/bitwarden"
                    ];
                  };
                };
              };
              super-s = {
                remap = {
                  super-e = {
                    launch = [
                      "${pkgs.bash}/bin/sh" "-c"
                      ''
                        ${pkgs.wl-clipboard}/bin/wl-paste --type image/png |
                        ${pkgs.swappy}/bin/swappy -f -
                      ''
                    ];
                  };
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
              super-u = {
                remap = {
                  super-f = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "history-pop" ];
                  };
                  super-d = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "close" ];
                  };
                  super-s = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "close-all" ];
                  };
                  super-c = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "action" ];
                  };
                  super-e = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "context" ];
                  };
                  super-t = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "set-paused" "toggle" ];
                  };
                  super-i = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "set-paused" "true" ];
                  };
                  super-o = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "set-paused" "false" ];
                  };
                };
              };
              super-f = {
                remap = {
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "1"];
                  };
                  super-i = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "2"];
                  };
                  super-o = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "3"];
                  };
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "4"];
                  };
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "5"];
                  };
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "6"];
                  };
                  super-l = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "7"];
                  };
                  super-semicolon = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "8"];
                  };
                  super-m = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "9"];
                  };
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "10"];
                  };
                };
              };
              super-e = {
                remap = {
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "1"];
                  };
                  super-i = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "2"];
                  };
                  super-o = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "3"];
                  };
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "4"];
                  };
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "5"];
                  };
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "6"];
                  };
                  super-l = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "7"];
                  };
                  super-semicolon = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "8"];
                  };
                  super-m = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "9"];
                  };
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "10"];
                  };
                };
              };
              super-v = {
                remap = {
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "1"];
                  };
                  super-i = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "2"];
                  };
                  super-o = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "3"];
                  };
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "4"];
                  };
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "5"];
                  };
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "6"];
                  };
                  super-l = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "7"];
                  };
                  super-semicolon = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "8"];
                  };
                  super-m = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "9"];
                  };
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "10"];
                  };
                };
              };

              super-d = {
                remap = {
                  super-c = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "killactive" ];
                  };
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "swapnext" ];
                  };
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "swapnext" "prev" ];
                  };
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "togglefloating" ];
                  };
                  super-f = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "fullscreen" ];
                  };
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "fullscreenstate" "1" ];
                  };
                  super-m = {
                    launch = [
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movewindow" "mon:+1"
                    ];
                  };
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "swapactiveworkspaces" "0" "1" ];
                  };
                  super-t = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "layoutmsg" "togglesplit" ];
                  };
                  super-g = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "focusurgentorlast" ];
                  };
                  super-s = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "layoutmsg" "swapsplit" ];
                  };
                };
              };

              super-comma = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "focusmonitor" "+1" ];
              };

              super-j = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "cyclenext" ];
              };
              super-k = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "cyclenext" "prev" ];
              };
              super-n = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "workspace" "r+1"];
              };
              super-p = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "workspace" "r-1" ];
              };
              super-semicolon = {
                # Seems this cannot be configured to work with empty workspaces
                # also
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "workspace" "previous_per_monitor" ];
              };
              super-y = {
                remap = {
                    super-s = {
                      launch = [ "${pkgs.playerctl}/bin/playerctl" "play-pause" ];
                  };
                    super-d = {
                      launch = [ "${pkgs.playerctl}/bin/playerctl" "next" ];
                  };
                    super-f = {
                      launch = [ "${pkgs.playerctl}/bin/playerctl" "previous" ];
                  };
                    super-e = {
                      launch = [ "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@"
                                        "toggle" ];
                  };
                };
              };
              super-i = {
                launch = [ "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@"
                  "5%-" ];
              };
              super-o = {
                launch = [ "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@"
                  "5%+" ];
              };
            };
          }
          {
            name = "to normal";
            remap = { super-space = {set_mode = "normal"; }; };
            mode = "default";
          }
          {
            name = "to default";
            remap = { super-space = {set_mode = "default"; }; };
            mode = "normal";
          }
          {
            mode = "normal";
            remap = {
              shift-h = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "-100" "0"
                ];
              };
              shift-j = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "0" "100"
                ];
              };
              shift-k = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "0" "-100"
                ];
              };
              shift-l = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "100" "0"
                ];
              };
              h = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "-100" "0"
                ];
              };
              j = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "0" "100"
                ];
              };
              k = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "0" "-100"
                ];
              };
              l = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "100" "0"
                ];
              };
              c = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "centerwindow"
                ];
              };
              semicolon = {
                launch = [
                  "${pkgs.brightnessctl}/bin/brightnessctl"
                  "set"
                  "10%+"
                ];
              };
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
              "shift-semicolon" = {
                launch = [
                  "${pkgs.brightnessctl}/bin/brightnessctl"
                  "set"
                  "100%"
                ];
              };
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
              super-b = [ "c-l" "shift-5" "space" ];
              super-c = {
                remap = {
                  super-c = "c-alt-z";
                  super-u = "alt-1";
                  super-i = "alt-2";
                  super-o = "alt-3";
                  super-p = "alt-4";
                  super-leftbrace =  "alt-5";
                  super-j = "alt-6";
                  super-k = "alt-7";
                  super-l = "alt-8";
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
              super-z = "c-shift-tab";
              super-x = "c-tab";
            };
            application = {
              "only" = "firefox";
            };
          }
        ];
      };
    };

  };
}
