{ config, inputs, pkgs, system, ... }:

let
  username = "admin";
  homeDirectory = "/home/${username}";
  ageFile = "${homeDirectory}/.config/sops/age/keys.txt";
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
    ./modules/hyprland.nix
    ./modules/xremap.nix
    ./modules/zsh.nix
    ./modules/fzf.nix
  ];
  nixpkgs.config.allowUnfree = true;
  home.username = username;
  home.homeDirectory = homeDirectory;
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.11";


  # Enable custom modules
  programs.sergio-hyprland.enable = true;
  programs.sergio-xremap.enable = true;
  programs.sergio-zsh.enable = true;
  programs.sergio-fzf.enable = true;

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
     vimPlugins.nvim-dbee
     cargo
     rust-analyzer
     clippy
     anki-bin
     playerctl
     wev
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
     # awscli2
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
          strColors = rice.palette.toRgbaHex colors;
        in
        strColors.charcoal;
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";
      };
    };
  };
  services.ssh-agent.enable = true;

  programs = {
    readline = {
      enable = true;
      variables = {
        editing-mode = "vi";
        keyseq-timeout = 0;
      };
    };
    rofi = {
      enable = true;
      package = pkgs.rofi;
      extraConfig = {
        show-icons = true;
        sorting-method = "fzf";
      };
      theme = let inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          bg = mkLiteral "rgba(40,44,60,0.6)";
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
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        opener = {
          images = [ 
            {
              run   = ''${pkgs.nsxiv}/bin/nsxiv "$@"'';
              orphan = true;
              desc  = "nsxiv (image viewer)";
            }
          ];
          docs = [
            {
              run   = ''${pkgs.zathura}/bin/zathura "$@"'';
              orphan = true;
              desc  = "zathura (document viewer)";
            }
          ];
          video = [
            {
              run   = ''${pkgs.mpv}/bin/mpv --fs "$@"'';
              orphan = true;
              desc  = "mpv (video player)";
            }
          ];
          edit = [
            {
              run   = ''${pkgs.neovim}/bin/nvim "$@"'';
              block = true;
              desc  = "Neovim (text editor)";
            }
          ];
        };
        open = {
          prepend_rules = [
            { mime = "image/*";  use = "images"; }
            { name = "*.pdf";    use = "docs";   }
            { name = "*.djvu";   use = "docs";   }
            { name = "*.epub";   use = "docs";   }
            { mime = "video/*";  use = "video";  }
            { mime = "text/*";   use = "edit";   }
          ];
        };
      };
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
      aliases = {
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
      # firefox
      "x-scheme-handler/http"  = [ "firefox.desktop" ];
      "x-scheme-handler/https"  = [ "firefox.desktop" ];
      "x-scheme-handler/chrome"  = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
    };
  };
}
