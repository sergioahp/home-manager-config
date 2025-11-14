{ config, lib, inputs, pkgs, system, ... }:

# TODO: PROBLEM:
# Launching with uwsm the rofi laucher is slower, but without it and the rest of
# the lauched programs close on each home-manager update


# PROBLEM: for some reason the rofi program laucher sometimes freeses instead of
# exiting

let
  username = "admin";
  homeDirectory = "/home/${username}";
  ageFile = "${homeDirectory}/.config/sops/age/keys.txt";

  # Import color utilities from the colors module
  inherit (config.lib.colors) transparentize colorToRgbaStr colorToRgbaLiteral rice intToFloat;
  colors = config.colorScheme.colors;
  colorsRgbHex = config.colorScheme.colorsRgbHex;
  nsxiv-conf = import ./nsxiv-conf-builder.nix { inherit pkgs; conf = {
    win_fg = {
      x_resource = "Nsxiv.window.background";
      value = colorsRgbHex.fg;
    };
    win_bg = {
      x_resource = "Nsxiv.window.background";
      value = colorsRgbHex.bg;
    };
    bar_bg = {
      x_resource = "Nsxiv.bar.background";
      value = colorsRgbHex.bg2;
    };
    bar_fg = {
      x_resource = "Nsxiv.bar.foreground";
      value = colorsRgbHex.electric-blue;
    };
  }; };
in
{
  nixpkgs.overlays = [
    (f: p: {
      nsxiv = p.nsxiv.override {
        conf = nsxiv-conf;
      };
      kitty = inputs.kitty-extended-keys.packages.${system}.default;
    })
  ];

  imports = [
    inputs.xremap.homeManagerModules.default
    inputs.sops-nix.homeManagerModules.sops
    ./modules/colors.nix
    ./modules/rofi.nix
    ./modules/zathura.nix
    ./modules/hyprland.nix
    ./modules/xremap.nix
    ./modules/zsh.nix
    ./modules/fzf.nix
    ./modules/yazi.nix
  ];
  nixpkgs.config.allowUnfree = true;
  home.username = username;
  home.homeDirectory = homeDirectory;
  systemd.user.startServices = "sd-switch";

  # Enable custom program modules
  programs.sergio-rofi.enable = true;
  programs.sergio-zathura.enable = true;

  home.stateVersion = "23.11";


  # Enable custom modules
  programs.sergio-hyprland.enable = true;
  programs.sergio-xremap.enable = true;
  programs.sergio-zsh.enable = true;
  programs.sergio-fzf.enable = true;
  programs.sergio-yazi.enable = true;

  home.packages = with pkgs; [
     nerd-fonts.dejavu-sans-mono
     noto-fonts
     noto-fonts-cjk-sans
     noto-fonts-color-emoji
    (python3.withPackages (ps: with ps; [
      numpy
      fabric
      python-lsp-server
      pylsp-mypy
      pandas
      torch
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
     vimPlugins.nvim-dbee
     cargo
     rust-analyzer
     clippy
     anki-bin
     playerctl
     wev
     nil
     clang-tools
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
     tor-browser
     tor
     torsocks
     atool
     imagemagick
     img2pdf
     ffmpeg
     bitwarden-desktop
     jq
     # awscli2
     element-desktop
     discord
     vscodium-fhs
     mullvad-browser
     trash-cli
     brave
     poppler-utils
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
     obs-studio
     dragon-drop
     pciutils
     usbutils
     speedtest-cli
     xsel
     bat
     fastfetch
     tree
     neovim
     copyq
     dust
     ripgrep
     whois
     nmap
     wl-clipboard
     pass # for protonbridge
     protonmail-bridge
     thunderbird
     socat
     eza
     hunspell
     hunspellDicts.es-mx
     claude-code
     codex
    # TODO: maybe manage with home manager
    kitty
     # jupyter-all # COLLITION
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # remember to git clone your external config
    # remember that the theme is also another git repo
    # todo: consider managing this with home manager(?)
    # fcitx5.ignoreUserConfig = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      kdePackages.fcitx5-qt
    ];
    fcitx5.waylandFrontend = true;

    # if you want to be able to add/change words on the dictionary, do not
    # manage this config with hm
    # fcitx5.settings.inputMethod = {
    #   GroupOrder."0" = "Default";
    #   "Groups/0" = {
    #     Name = "Default";
    #     "Default Layout" = "us-altgr-intl";
    #     DefaultIM = "mozc";
    #   };
    #
    #   "Groups/0/Items/0".Name = "us-altgr-intl";
    #   "Groups/0/Items/1".Name = "mozc";
    # };
  };

  sops = {
    age.keyFile = ageFile;
    defaultSopsFile = ./secrets.yaml;
    secrets."avante/anthropic" = { };
  };

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

  systemd.user.services.protonbridge = {
    Unit = {
      Description = "ProtonMail Bridge Service";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive --log-level info";
      Restart = "on-failure";
      RestartSec = 30;
    };

    Install = {
      WantedBy = [ "default.target" ];
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

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
    };
  };
  services.dunst = {
    enable = true;
    settings = {
      global = {
        background = let
          charcoal-38 = transparentize colors.charcoal 0.3764705882352941;  # 38% opacity
        in
        rice.color.toRgbaHex charcoal-38;
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";
        origin = "top-left";
      };
      hyprvoice = let
        pale-red-38 = transparentize colors.pale-red 0.3764705882352941;  # 38% opacity, same as charcoal
      in {
        appname = "Hyprvoice";
        background = rice.color.toRgbaHex pale-red-38;
        frame_color = rice.color.toRgbHex colors.pale-red;
      };
    };
  };
  services.ssh-agent.enable = true;

  services.hyprvoice = {
    enable = true;
    settings = {
      transcription = {
        provider = "openai";
        language = "";
        model = "whisper-1";
      };
      injection = {
        mode = "fallback";
        restore_clipboard = true;
      };
    };
  };

  programs = {
    readline = {
      enable = true;
      variables = {
        editing-mode = "vi";
        keyseq-timeout = 0;
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
      settings = {
        user.name = "sergioahp";
        user.email = "sergioahp@proton.me";
        user.signingkey = "4E3F5ADE5C10EDB6";
        init.defaultBranch = "master";
        commit.gpgsign = true;
        tag.gpgSign = true;
        merge.tool = "vimdiff";
        mergetool.vimdiff.cmd = "${pkgs.neovim}/bin/nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
        diff.tool = "vimdiff";
        difftool.vimdiff.cmd = "${pkgs.neovim}/bin/nvim -d $LOCAL $REMOTE";
        alias = {
          a   = "add";
          s   = "status";
          f   = "fetch";
          u   = "pull";
          l   = "log         -n 15   --oneline --decorate";
          lg  = "log         --graph --oneline --decorate";
          lga = "log --all   --graph --oneline --decorate";
          co  = "checkout";
          c   = "commit -v";
          ca  = "commit -v --amend";
          b   = "branch";
          d   = "diff                      -M -C -C --color-moved --color-moved-ws=allow-indentation-change";
          dw  = "diff          --word-diff -M -C -C --color-moved --color-moved-ws=allow-indentation-change";
          ds  = "diff --staged             -M -C -C --color-moved --color-moved-ws=allow-indentation-change";
          dsw = "diff --staged --word-diff -M -C -C --color-moved --color-moved-ws=allow-indentation-change";
          st  = "stash";
        };
      };
    };
    alacritty = {
      enable = true;
      settings = let
        strColors = rice.palette.toRgbHex colors;
        bg-80 = transparentize colors.bg 0.8;  # 80% opacity
      in {
        window.opacity = (rice.float.toFloat bg-80.a) / 255.0;
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
      profiles.default = {
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
          "editor.rulers" = [80];
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
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
        };
        "github" = {
          host = "github.com";
          user = "git";
          identityFile = [
            "${homeDirectory}/.ssh/main"
          ];
        };
      };
    };
    chromium.enable = true;
    home-manager.enable = true;
    sagemath.enable = true;
    mpv.enable = true;
  };
  home.shellAliases = {

    sudo = "sudo ";
    g = "git";
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
      # documents
      "image/vnd.djvu" = [ "org.pwmt.zathura.desktop" ];
      "image/x-djvu" = [ "org.pwmt.zathura.desktop" ];
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      # firefox
      "x-scheme-handler/http"  = [ "firefox.desktop" ];
      "x-scheme-handler/https"  = [ "firefox.desktop" ];
      "x-scheme-handler/chrome"  = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
    };
  };
}
