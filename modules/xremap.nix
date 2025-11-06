{ config, lib, pkgs, inputs, system, ... }:
let
  cfg = config.programs.sergio-xremap;
  xremapCfg = {
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
                launch-and-description = {
                  description = "Terminal";
                  launch = [
                    "${pkgs.uwsm}/bin/uwsm" "app" "--"
                    "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                    "${pkgs.kitty}/bin/kitty"
                  ];
                };
              };
              super-f = {
                launch-and-description = {
                  description = "Firefox Browser";
                  launch = [
                    "${pkgs.uwsm}/bin/uwsm" "app" "--"
                    "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                    "${pkgs.firefox}/bin/firefox"
                  ];
                };
              };
              super-e = {
                launch-and-description = {
                  description = "File Manager (Ranger)";
                  launch = [
                    "${pkgs.uwsm}/bin/uwsm" "app" "--"
                    "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                    "${pkgs.kitty}/bin/kitty"
                    "${pkgs.ranger}/bin/ranger"
                  ];
                };
              };
              super-o = {
                launch-and-description = {
                  description = "System Monitor (btop)";
                  launch = [
                    "${pkgs.uwsm}/bin/uwsm" "app" "--"
                    "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                    "${pkgs.kitty}/bin/kitty"
                    "${pkgs.btop}/bin/btop"
                  ];
                };
              };
              super-m = {
                launch-and-description = {
                  description = "Application Launcher (Rofi)";
                  launch = [
                    # bug: hyprctl does not work with commands containing semicolons
                    # Do not use "${pkgs.uwsm}/bin/uwsm" "app" "--" it makes
                    # this slow but we need this to be really fast
                    "${pkgs.rofi}/bin/rofi" "-show" "drun"
                     "-theme-str" "window {width: 20%;}"
                  ];
                };
              };
              super-k = {
                launch-and-description = {
                  description = "Quick Start Menu";
                  launch = [
                    "${inputs.rofi-switch-rust.packages.${system}.default}/bin/quick-start"
                  ];
                };
              };
              super-i = {
                launch-and-description = {
                  description = "Password Manager (Bitwarden)";
                  launch = [
                    "${pkgs.uwsm}/bin/uwsm" "app" "--"
                    "${pkgs.bitwarden-desktop}/bin/bitwarden"
                  ];
                };
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

  # Recursively process config to extract launch descriptions and convert to xremap format
  # Returns: { config = <xremap-compatible-config>; descriptions = [ { key = "..."; description = "..."; } ] }
  processLaunchDescriptions = keyPath: cfg':
    let
      # Check if this is a launch-and-description attribute
      isLaunchWithDescription = builtins.isAttrs cfg' && cfg' ? launch-and-description;

      # Process a single attribute set
      processAttrs = attrs:
        let
          processed = lib.mapAttrs (name: value:
            let newPath = if keyPath == "" then name else "${keyPath} ${name}";
            in processLaunchDescriptions newPath value
          ) attrs;
          configs = lib.mapAttrs (name: value: value.config) processed;
          descriptions = lib.flatten (lib.mapAttrsToList (name: value: value.descriptions) processed);
        in { config = configs; descriptions = descriptions; };
    in
      if isLaunchWithDescription then
        # Convert launch-and-description to launch and extract description
        {
          config = { launch = cfg'.launch-and-description.launch; };
          descriptions = [{
            key = keyPath;
            description = cfg'.launch-and-description.description;
          }];
        }
      else if builtins.isAttrs cfg' then
        # Recursively process nested attributes
        processAttrs cfg'
      else if builtins.isList cfg' then
        # Process lists
        let
          processed = lib.imap0 (i: value:
            let newPath = if keyPath == "" then "${builtins.toString i}" else "${keyPath} ${builtins.toString i}";
            in processLaunchDescriptions newPath value
          ) cfg';
          configs = map (x: x.config) processed;
          descriptions = lib.flatten (map (x: x.descriptions) processed);
        in { config = configs; descriptions = descriptions; }
      else
        # Base case: return as-is
        { config = cfg'; descriptions = []; };

  # Process the config to extract descriptions and convert to xremap format
  processed = processLaunchDescriptions "" xremapCfg;

  # The xremap-compatible config
  xremapConfig = processed.config;

  # The descriptions for rofi menu (list of { key, description })
  launchDescriptions = processed.descriptions;

in {
  imports = [];
  options = {
    programs.sergio-xremap = {
      enable = lib.mkEnableOption "sergio's xremap configuration";

      # Expose launch descriptions for use in rofi menu
      launchDescriptions = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.str);
        readOnly = true;
        default = launchDescriptions;
        description = "List of launch commands with their descriptions for rofi menu generation";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.xremap = {
      # yes, you as per a gh issue, one should use this
      # instead of withHypr
      withWlroots = true;
      config = xremapConfig;
    };

  };
}
