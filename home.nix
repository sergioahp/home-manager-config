{ config, inputs, pkgs, ... }:

{

  imports = [
    inputs.xremap.homeManagerModules.default
  ];
  nixpkgs.config.allowUnfree = true;
  home.username = "admin";
  home.homeDirectory = "/home/admin";

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
     nerd-fonts.dejavu-sans-mono
     noto-fonts
     noto-fonts-cjk-sans
     noto-fonts-emoji
    (python3.withPackages (ps: with ps; [
      numpy
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
     nil
     tinymist
     typst
     typst-live
     typstfmt
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
     ranger
     tree
     neovim
     copyq
     du-dust
     fzf
     ripgrep
     tmux
     whois
     nmap
     wl-clipboard
     pass # for protonbridge
     protonmail-bridge
     socat
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

  home.sessionVariables = {
     EDITOR = "nvim";
     XDDD = "echo";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        kb_options = "caps:swapescape";
        repeat_delay = 250;
        repeat_rate = 70;
        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = true;
        };
      };
      bind = [
      "$mod, Q, exit"
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
                super-k = {
                  launch = [ "${pkgs.alacritty}/bin/alacritty" ];
              };
                super-f = {
                  launch = [ "${pkgs.firefox}/bin/firefox" ];
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
          super-d = {
            remap = {
                super-c = {
                  launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                  "killactive" ];
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
          };
          # super-f = {
          #   remap = {
          #   };
          # };
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
    gh = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "sergioahp";
      userEmail = "sergioahp@proton.me";
      extraConfig = {
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
    };
    chromium.enable = true;
    home-manager.enable = true;
    sagemath.enable = true;
    zathura.enable = true;
    mpv.enable = true;
    zsh = {
      enable = true;
      defaultKeymap = "viins";
      enableCompletion = true;
      history = {
        append = true;
      };
      syntaxHighlighting.enable = true;
      initExtra = ''
        bindkey -v '^?' backward-delete-char
        # fzf configuration
        if [ -n "''${commands[fzf-share]}" ]; then
          source "$(fzf-share)/key-bindings.zsh"
          source "$(fzf-share)/completion.zsh"
        fi

        # Custom fzf keybindings for vim mode
        bindkey -M vicmd '/' fzf-history-widget
        bindkey -M viins '^R' fzf-history-widget
        bindkey -M vicmd '^T' fzf-file-widget
        bindkey -M viins '^T' fzf-file-widget
        bindkey -M vicmd '^P' fzf-cd-widget
        bindkey -M viins '^P' fzf-cd-widget

        # fzf-tab configuration
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

        # Additional fzf options
        export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
        export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
      '';
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
  home.shellAliases = {
    ls = "eza";
  };
}
