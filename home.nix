{ config, inputs, pkgs, system, ... }:

let
  username = "admin";
  homeDirectory = "/home/${username}";
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

  gtk.enable = true;
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
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      "$mod" = "SUPER";
      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        kb_options = "caps:swapescape";
        repeat_delay = 250;
        repeat_rate = 50;
        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = true;
        };
      };
      bind = [
      "$mod, Q, exit"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
      ];
    };
  };
  services.hyprpaper = {
    enable = false;
  };
  services.ssh-agent.enable = true;

  services.flameshot.enable = true;
  services.xremap = {
    withHypr = true;
    config = {
      keymap = [
      {
        name = "main remaps";
        remap = {
          super-m = {
            remap = {
                super-l = {
                  launch = [ "systemd-run" "--user" "--scope" "${pkgs.alacritty}/bin/alacritty" ];
              };
                super-f = {
                  launch = [ "systemd-run" "--user" "--scope" "${pkgs.firefox}/bin/firefox" ];
              };
                super-e = {
                  launch = [ "${pkgs.alacritty}/bin/alacritty" "-e"
                  "${pkgs.ranger}/bin/ranger" ];
              };
                super-o = {
                  launch = [ "${pkgs.alacritty}/bin/alacritty" "-e"
                  "${pkgs.btop}/bin/btop" ];
              };
                super-m = {
                  launch = [ "${pkgs.wofi}/bin/wofi" "--show" "drun" ];
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
        };
      }
      {
        name = "other remaps";
        remap = {
          super-g = "a";
        };
        application = {
          "only" = [ "firefox" ];
        };
      }
      ];
    };
  };

  programs = {
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
      settings = {
        window.opacity = 0.9;
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
      options = {
        selection-clipboard = "clipboard";
        statusbar-home-tilde = true;
        window-title-basename = true;
        default-bg = "rgba(31,32,38,0.7)";
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
        # Temporary, gnome overides the other var so we overide back
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
