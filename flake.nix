{
  description = "Home Manager configuration of admin";


  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Bleeding edge nixpkgs for latest packages (opencode, etc.)
    nixpkgs-bleeding.url = "github:nixos/nixpkgs/nixos-unstable";
    # Slow-moving nixpkgs for packages that are infrequently updated or take too long to update
    # Used for: kitty-extended-keys, nix-rice, rofi-switch-rust (and potentially others to be migrated gradually)
    # Updated manually with: nix flake lock --update-input nixpkgs-slow-moving
    nixpkgs-slow-moving.url = "github:nixos/nixpkgs/nixos-unstable";
    # Pinned nixpkgs for bitwarden (newer versions have issues)
    # Keep at working commit - update manually only when tested
    nixpkgs-bitwarden-zathura.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap.url = "github:sergioahp/nix-flake?ref=feature/use-sergio-xremap-fork";
    hyprswitch.url = "github:h3rmt/hyprswitch/release";
    nix-rice = {
      url = "github:bertof/nix-rice";
      inputs.nixpkgs.follows = "nixpkgs-slow-moving";
    };
    gtk-status-bar.url = "github:sergioahp/gtk-status-bar";
    kitty-extended-keys = {
      # Branch off the pre-flake-parts-refactor commit; adds ctrl+shift+f extended key.
      url = "github:sergioahp/kitty-extended-keys/feat/enable-ctrl-shift-f";
      inputs.nixpkgs.follows = "nixpkgs-slow-moving";
    };
    rofi-switch-rust = {
      url = "github:sergioahp/rofi-switch-rust";
      inputs.nixpkgs.follows = "nixpkgs-slow-moving";
    };
    hyprvoice.url = "github:sergioahp/hyprvoice/feature/context-transcription";
    rofi-power-menu = {
      url = "github:sergioahp/rofi-power-menu";
      flake = false;
    };
    dunst-src = {
      url = "github:sergioahp/dunst/feature/action-history-timeout";
      flake = false;
    };
    rofi-src = {
      # git scheme (not github:) so submodules=1 fetches subprojects/libgwater.
      url = "git+https://github.com/sergioahp/rofi.git?ref=feature/mm-fzf-matching&submodules=1";
      flake = false;
    };
    status-overlay.url = "github:sergioahp/status-overlay";
    typst-languagetool-nix.url = "github:sergioahp/typst-languagetool-nix";
    fcitx5-fzf-table = {
      url = "github:sergioahp/fcitx5-fzf-table";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Single source for everything llm-agents-related here: its packages
    # provide claude-code, codex and claude-desktop, and an overlay below
    # takes hermes-* straight off dendritic.inputs.llm-agents, so one numtide
    # pin serves everything instead of two that drift apart.
    #
    # Its claude-code wrap points CLAUDE_CODE_SHELL at a bash whose BASH_ENV
    # carries the shell aliases with the ones claude runs constantly
    # (cat/ls/rm/...) removed, which replaces the in-claude-else script this
    # repo used to dispatch on $CLAUDECODE at runtime. Deliberately not
    # following our nixpkgs: the wrap is a symlinkJoin over llm-agents'
    # package, and llm-agents builds against its own pin, which is what
    # cache.numtide.com serves.
    #
    # github: rather than a path: input, which would copy the whole working
    # tree (desktop.qcow2 included) into the store. Local dendritic edits
    # therefore need a push plus `nix flake update dendritic` to land here.
    dendritic.url = "github:sergioahp/dendritic-nix-config";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      dendritic-pkgs = inputs.dendritic.packages.${system};
      # Reached through dendritic's input graph rather than as a second
      # top-level llm-agents input, so there is exactly one numtide pin and
      # our flake.lock records it (as dendritic's "llm-agents" node).
      llm-agents-pkgs = inputs.dendritic.inputs.llm-agents.packages.${system};
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          # Upstream's overlays.default is gone (blueprint removal) and its
          # remaining overlays.shared-nixpkgs would rebuild everything against
          # our nixpkgs, missing cache.numtide.com. So inject the package set
          # verbatim as pkgs.llm-agents, an escape hatch for the ~200 agents
          # not named below, and hoist the ones we install to the top level so
          # every consumer resolves to one instance rather than whichever
          # llm-agents attr path it happened to use.
          #
          # Not dendritic.overlays.default: that one also carries dendritic's
          # neovim-with-tools, nsxiv, zsh, fzf, tmux, yazi, zathura and btop,
          # which would displace this repo's own versions of all of those.
          #
          # claude-desktop carries dendritic's HYPRLAND_INSTANCE_SIGNATURE-
          # gated --password-store=gnome-libsecret flag, which replaces this
          # repo's old unconditional keyring wrapper overlay.
          (final: prev: {
            llm-agents = llm-agents-pkgs;
            inherit (llm-agents-pkgs) hermes-agent hermes-desktop;
            inherit (dendritic-pkgs) claude-code codex claude-desktop;
          })
          # pylsp-mypy's test suite runs mypy over the package's own
          # pyproject.toml, which pins python_version = "3.9"; current mypy
          # refuses anything below 3.10, so 7 of 39 tests fail on that one
          # line. Upstream master still carries the 3.9 pin and 0.7.0
          # (2025-01) is still the newest release, so the fix has to come from
          # a nixpkgs patch, not a version bump. Recheck by building
          # nixpkgs#python3Packages.pylsp-mypy unpatched.
          (final: prev: {
            pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
              (pyfinal: pyprev: {
                pylsp-mypy = pyprev.pylsp-mypy.overridePythonAttrs (old: {
                  doCheck = false;
                });
              })
            ];
          })
        ];
      };
      pkgs-bleeding = import inputs.nixpkgs-bleeding {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-slow-moving = import inputs.nixpkgs-slow-moving {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      homeConfigurations = {
        nixd = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
            ./machines/nixd.nix
          ];

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-bleeding; inherit pkgs-slow-moving; };
        };

        laptop = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
            ./machines/laptop.nix
          ];

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-bleeding; inherit pkgs-slow-moving; };
        };
      };

      # Export zsh module for reuse in other flakes
      homeManagerModules = {
        sergio-zsh = ./modules/zsh.nix;
      };
    };
}
