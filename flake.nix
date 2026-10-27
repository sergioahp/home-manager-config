{
  description = "Home Manager configuration of admin";


  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Slow-moving nixpkgs for packages that are infrequently updated or take too long to update
    # Used for: kitty-extended-keys, nix-rice, rofi-switch-rust (and potentially others to be migrated gradually)
    # Updated manually with: nix flake lock --update-input nixpkgs-slow-moving
    nixpkgs-slow-moving.url = "github:nixos/nixpkgs/nixos-unstable";
    # Keep at working commit - update manually only when tested. Held back
    # for zathura, whose newer builds are still not where we want them
    # visually (rechecked 2026-08); layan-gtk-theme rides along.
    nixpkgs-zathura-layan.url = "github:nixos/nixpkgs/nixos-unstable";
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
    hyprvoice.url = "github:sergioahp/hyprvoice/master";
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
    ocr-gui.url = "github:sergioahp/ocr-gui";
    typst-languagetool-nix.url = "github:sergioahp/typst-languagetool-nix";
    fcitx5-fzf-table = {
      url = "github:sergioahp/fcitx5-fzf-table";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Agent packages; Hermes comes from dendritic's llm-agents input.
    dendritic.url = "github:sergioahp/dendritic-nix-config";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      dendritic-pkgs = inputs.dendritic.packages.${system};
      # Reuse dendritic's llm-agents pin for Hermes.
      llm-agents-pkgs = inputs.dendritic.inputs.llm-agents.packages.${system};
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          # Use selected agent packages without dendritic's unrelated overrides.
          (final: prev: {
            llm-agents = llm-agents-pkgs;
            inherit (llm-agents-pkgs) hermes-agent hermes-desktop;
            inherit (dendritic-pkgs) claude-code claude-desktop codex omp opencode;
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

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-slow-moving; };
        };

        laptop = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
            ./machines/laptop.nix
          ];

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-slow-moving; };
        };
      };

      # Export zsh module for reuse in other flakes
      homeManagerModules = {
        sergio-zsh = ./modules/zsh.nix;
      };
    };
}
