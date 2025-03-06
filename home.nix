{ config, inputs, pkgs, system, ... }:

let
  username = "admin";
  homeDirectory = "/home/${username}";
  rice = inputs.nix-rice.lib.nix-rice;
  # TODO: find better highlighting colors
  colors = rice.palette.tPalette rice.color.hexToRgba {
    bg = "#282c3ccc";
    charcoal = "#1f202660";
    bg2 = "#1e2030";
    fg2 = "#c8d3f5";
    highlight = "#2d3f7699";
    highlight-active = "#ff966c99";
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
  };
 colorsRgbHex = rice.palette.toRgbHex colors;
  intToFloat = rice.float.toFloat;
  # todo: Alpha modifiers
  colorToRgbaStr  = { r, g, b, a? 255 }:
    let f = pkgs.lib.strings.floatToString; i = toString; in
      "rgba(${i(r)},${i(g)},${i(b)},${f((intToFloat a) / 255.0)})";
in
{

  imports = [
    inputs.xremap.homeManagerModules.default
  ];
  nixpkgs.config.allowUnfree = true;
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
     nerd-fonts.dejavu-sans-mono
     noto-fonts
     noto-fonts-cjk-sans
     noto-fonts-emoji
    (python3.withPackages (ps: with ps; [
      numpy
      fabric
      python-lsp-server
      pylsp-mypy
      pandas
      pytorch
      torchvision
      matplotlib
      ipykernel
      scipy
      pip
      virtualenv
      notebook
     ]))
     ltex-ls-plus
     inputs.hyprswitch.packages.${system}.default
     nil
     tinymist
     typst
     typst-live
     typstfmt
     firefox
     lua-language-server
     gcc
     gnumake
     ripgrep
     fd
     yt-dlp
     wget
     wget2
     aria2
     tor-browser-bundle-bin
     tor
     torsocks
     atool
     imagemagick
     img2pdf
     ffmpeg
     bitwarden
     jq
     awscli2
     element-desktop
     discord
     vscodium-fhs
     mullvad-browser
     trash-cli
     brave
     poppler_utils
     hwinfo
     inxi
     nix-index
     session-desktop
     pandoc
     httpie
     mat2
     exiftool
     exiv2
     file
     rsync
     wireshark
     transmission_4
     nsxiv
     ripgrep
     pv
     ncpamixer
     nvd
     nh
     libreoffice
     ghostscript
     gimp
     xdragon
     pciutils
     usbutils
     speedtest-cli
     xsel
     bat
     fastfetch
     tree
     neovim
     copyq
     du-dust
     ripgrep
     whois
     nmap
     wl-clipboard
     pass # for protonbridge
     protonmail-bridge
     socat
     eza
     # jupyter-all # COLLITION
  ];

  services.podman = {
    enable = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      # We add the emoji family as a workarround to other font's emojis taking precedence
      # https://github.com/NixOS/nixpkgs/issues/172412
      serif = [ "DejaVu Serif" "emoji" ];
      sansSerif = [ "DejaVu Sans" "noto-fonts-cjk" "emoji" ];
      monospace = [ "DejaVu Sans Mono" "emoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  home.file = {
  };

  gtk = {
    enable = true;
    theme = {
      name = "Layan-Dark";
      package = pkgs.layan-gtk-theme;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interfase" = {
        color-scheme = "prefer-dark";
      };
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";

  };
  home.pointerCursor = {
    # package = pkgs.vanilla-dmz;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
    gtk.enable = true;
  };

  home.sessionVariables = {
     EDITOR = "${pkgs.neovim}/bin/nvim";
     MANPAGER = "${pkgs.neovim}/bin/nvim +Man!=";
     GTK_THEME = "Layan-Dark";
  };

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
        gaps_out = 6;
        "col.active_border" = "0xff6d80c9";
      };
      decoration = {
        blur = {
          passes = 2;
          size = 3;
          noise = 0.055;
          # vibrancy = 0.4;
          vibrancy_darkness = 0.4;
        };
        shadow = {
          range = 4;
          render_power = 2;
          color = "0xee6d80c9";
          color_inactive = "0x001a1a1a";
        };
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
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      layerrule = [
        "blur, rofi"
        "blur, notifications"
      ];
    };
  };
  services.hyprpaper = {
    enable = false;
  };
  services.dunst = {
    enable = true;
    settings = {
      global = {
        background = let
          strColors = rice.palette.toRgbaHex colors;
        in
        strColors.charcoal;
        dmenu = "${pkgs.rofi-wayland}/bin/rofi -dmenu -p dunst";
      };
    };
  };
  services.ssh-agent.enable = true;

  services.xremap = {
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
                    "${pkgs.alacritty}/bin/alacritty"
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
                    "${pkgs.alacritty}/bin/alacritty" "-e"
                    "${pkgs.ranger}/bin/ranger"
                  ];
                };
                super-o = {
                  launch = [
                    "${pkgs.uwsm}/bin/uwsm" "app" "--"
                    "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                    "${pkgs.alacritty}/bin/alacritty" "-e"
                    "${pkgs.btop}/bin/btop"
                  ];
                };
                super-m = {
                  launch = [
                    # bug: hyprctl does not work with commands containing semicolons
                    "${pkgs.uwsm}/bin/uwsm" "app" "--"
                    "${pkgs.rofi-wayland}/bin/rofi" "-show" "drun"
                     "-theme-str" "window {width: 20%;}"
                  ];
                };
                super-k = {
                  launch = [
                    "${pkgs.uwsm}/bin/uwsm" "app" "--"
                    "${pkgs.rofi-wayland}/bin/rofi" "-show" "window"
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
                      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - |
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
                super-leftbrace = {
                  launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                  "movewindow" "mon:l" ];
                };
                super-rightbrace = {
                  launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                  "movewindow" "mon:r" ];
                };
                super-s = {
                  launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                  "swapactiveworkspaces" "0" "1" ];
                };
              };
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
              "workspace" "+1"];
            };
            super-p = {
              launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
              "workspace" "-1" ];
            };
            super-semicolon = {
              launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
              "workspace" "previous" ];
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
                    launch = [ "${pkgs.pipewire}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@"
                                      "toggle" ];
                };
              };
              super-i = {
                launch = [ "${pkgs.pipewire}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@"
                  "5%+" ];
              };
              super-o = {
                launch = [ "${pkgs.pipewire}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@"
                  "5%-" ];
              };
            };
          };
        }
        {
          name = "other remaps";
          remap = {
            super-b = [ "c-l" "shift-5" "space" ];
          };
          application = {
            "only" = [ "firefox" ];
          };
        }
      ];
    };
  };

  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      extraConfig = {
        show-icons = true;
        sorting-method = "fzf";
      };
      theme = let inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          bg = mkLiteral "rgba(40,44,60,0.7)";
          fg0 = mkLiteral "#bb8af7";
          accent-color = mkLiteral "#88C0D0";
          urgent-color = mkLiteral "#EBCB8B";
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
        };
        "element normal active" = {
          text-color = mkLiteral "@accent-color";
        };
        "element selected normal, element selected active" = {
          background-color = mkLiteral "@accent-color";
        };
        "element-text" = {
            text-color = mkLiteral "inherit";
        };
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    eww = {
      enable = true;
      configDir = ./eww;
    };
    ranger = {
      enable = true;
      rifle = [
        {
          condition = "mime ^image, flag f";
          command = ''${pkgs.nsxiv}/bin/nsxiv -- "$@"'';
        }
        {
          condition = "ext pdf|djvu|epub, flag f";
          command = ''${pkgs.zathura}/bin/zathura -- "$@"'';
        }
        {
          condition = "mime ^video, flag f";
          command = ''${pkgs.mpv}/bin/mpv --fs -- "$@"'';
        }
        {
          condition = "mime ^text";
          command = ''${pkgs.neovim}/bin/nvim "$@"'';
        }
      ];
    };
    tmux = {
      enable = true;
      terminal = "tmux-256color";
      escapeTime = 0;
      prefix = "C-a";
      keyMode = "vi";
      historyLimit = 5000;
      extraConfig = ''
      '';
    };
    gh = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "sergioahp";
      userEmail = "sergioahp@proton.me";
      extraConfig = {
        init.defaultBranch = "master";
        user.signingkey = "4E3F5ADE5C10EDB6";
        commit.gpgsign = true;
        tag.gpgSign = true;
        merge.tool = "vimdiff";
        mergetool.vimdiff.cmd = "${pkgs.neovim}/bin/nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
        diff.tool = "vimdiff";
        difftool.vimdiff.cmd = "${pkgs.neovim}/bin/nvim -d $LOCAL $REMOTE";
      };
    };
    alacritty = {
      enable = true;
      settings = let
        strColors = rice.palette.toRgbHex colors;
      in {
        window.opacity = (rice.float.toFloat colors.bg.a) / 255.0;
        colors = {
          primary = {
            background = strColors.bg;
            foreground = strColors.fg;
          };
          normal = {
            red     = strColors.red;
            green   = strColors.green;
            yellow  = strColors.yellow;
            blue    = strColors.blue;
            magenta = strColors.magenta;
            cyan    = strColors.cyan;
            white   = strColors.fg-dark;
          };
          bright = {
            red     = strColors.bright-red;
            green   = strColors.bright-green;
            yellow  = strColors.bright-yellow;
            blue    = strColors.bright-blue;
            magenta = strColors.bright-magenta;
            cyan    = strColors.bright-cyan;
            white   = strColors.fg;
          };
          indexed_colors = [
            # where do they apply?
            { index = 16; color = strColors.orange; }
            { index = 17; color = strColors.red1; }
          ];
        };
      };
    };
    btop = {
      enable = true;
      settings = {
        theme_background = false;
        vim_keys = true;
      };
    };
    vscode = {
      enable = true;
      mutableExtensionsDir = false;
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-toolsai.jupyter
        ms-python.python
        vscodevim.vim
        myriad-dreamin.tinymist
      ];
      userSettings = {
        "keyboard.dispatch" = "keyCode";
        "remote.SSH.configFile" = "~/ssh/config";
        "remote.SSH.defaultExtensions" = [
          "ms-toolsai.jupyter"
          "ms-python.python"
        ];
        "telemetry.telemetryLevel" = "off";
        "telemetry.enableTelemetry" = false;
        "telemetry.enableCrashReporter" = false;
        "workbench.enableExperiments" = false;
        "workbench.settings.enableNaturalLanguageSearch" = true;
        "update.enableWindowsBackgroundUpdates" = false;
        "extensions.autoCheckUpdates" = false;
        "extensions.autoUpdate" = false;
      };
    };
    ssh = {
      enable = true;
      addKeysToAgent =  "yes";
      matchBlocks."github" = {
        host = "github.com";
        user = "git";
        identityFile = [
          "${homeDirectory}/.ssh/main"
        ];
      };


    };
    chromium.enable = true;
    home-manager.enable = true;
    sagemath.enable = true;
    zathura = {
      enable = true;
      options = let
        rgba = colorToRgbaStr;
      in {
        selection-clipboard = "clipboard";
        statusbar-home-tilde = true;
        window-title-basename = true;
        default-bg = rgba colors.bg;
        statusbar-bg = rgba colors.bg2;
        statusbar-fg = rgba colors.electric-blue;
        # bug: no alpha support on the inputbar-bg
        inputbar-bg = rgba colors.bg;
        inputbar-fg = rgba colors.electric-blue2;
        notification-error-bg = rgba colors.bg;
        notification-warning-bg = rgba colors.bg;
        notification-bg = rgba colors.bg;
        notification-error-fg = rgba colors.red2;
        notification-warning-fg = rgba colors.yellow2;
        notification-fg = rgba colors.electric-blue2;
        highlight-active-color = rgba colors.highlight-active;
        highlight-color = rgba colors.highlight;
        completion-bg = rgba colors.bg2;
        completion-fg = rgba colors.fg2;
        completion-highlight-bg = rgba colors.highlight;
        completion-highlight-fg = rgba colors.cyan2;
        recolor-lightcolor = "rgba(0,0,0,0)";
        recolor-keephue = true;
        recolor = true;
      };
      mappings = {
        i = "recolor";
      };
    };
    mpv.enable = true;
    zsh = {
      enable = true;
      defaultKeymap = "viins";
      enableCompletion = true;
      history = {
        append = true;
      };
      syntaxHighlighting.enable = true;
      autosuggestion = {
        enable = true;
      };
      initExtra = ''
        bindkey -v '^?' backward-delete-char
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        bindkey ^K fzf-cd-widget
        bindkey ^J fzf-file-widget
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd ^F edit-command-line
        bindkey ^F edit-command-line
        # Temporary, gnome overrides the other var so we override back
        export EDITOR=nvim
        preexec() {
          local cmd="''${1%% *}"
          printf "\e]0;%s\a" "$cmd"
        }
      '';
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--layout=reverse"
        "--info=inline"
      ];
      historyWidgetOptions = [
        "--with-nth 2.."
      ];
      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --style=plain --color=always --line-range :500 {}'"
      ];
      changeDirWidgetOptions = [
        "--preview '${pkgs.eza}/bin/eza -T --color=always {} | head -200'"
      ];
    };
  };
  home.shellAliases = {

    sudo = "sudo ";
    ls = "${pkgs.eza}/bin/eza";
    mv = "mv -i";
    cp = "cp -i";
    rm = "rm -I";
    tree = "${pkgs.eza}/bin/eza -T";
    cat = "${pkgs.bat}/bin/bat --paging=never --style=plain";
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      #
      "image/bmp" = [ "nsxiv.desktop" ];
      "image/gif" = [ "nsxiv.desktop" ];
      "image/jpeg" = [ "nsxiv.desktop" ];
      "image/png" = [ "nsxiv.desktop" ];
      "image/tiff" = [ "nsxiv.desktop" ];
      "image/x-bmp" = [ "nsxiv.desktop" ];
      "image/x-portable-bitmap" = [ "nsxiv.desktop" ];
      "image/x-portable-graymap"  = [ "nsxiv.desktop" ];
      "image/x-tga"  = [ "nsxiv.desktop" ];
      "image/x-xpixmap" =  [ "nsxiv.desktop" ];
      "image/webp"  = [ "nsxiv.desktop" ];
      "image/heic"  = [ "nsxiv.desktop" ];
      "image/svg+xml"  = [ "nsxiv.desktop" ];
      "application/postscript"  = [ "nsxiv.desktop" ];
      "image/jp2" =  [ "nsxiv.desktop" ];
      "image/jxl" =  [ "nsxiv.desktop" ];
      "image/avif"  = [ "nsxiv.desktop" ];
      "image/heif"  = [ "nsxiv.desktop" ];
      # firefox
      "x-scheme-handler/http"  = [ "firefox.desktop" ];
      "x-scheme-handler/https"  = [ "firefox.desktop" ];
      "x-scheme-handler/chrome"  = [ "firefox.desktop" ];
    };
  };
}
