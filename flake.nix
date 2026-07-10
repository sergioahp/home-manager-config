{
  description = "Home Manager configuration of admin";

  # Binary cache for llm-agents.nix (claude-code, codex); their packages are
  # built against their own pinned nixpkgs so this cache hits regardless of
  # our nixpkgs revision.
  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # hyprland pinned to v0.49.0 (last known stable on desktop)
    # Why tf did you pinned this, claude?
    # last thing that produces a good config != last stable  on desktop
    hyprland.url = "github:hyprwm/Hyprland/v0.49.0";
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
    # Daily-updated AI coding agents (claude-code, codex). No nixpkgs follows=
    # on purpose: overlays.default builds against their pinned nixpkgs, which
    # is what the numtide binary cache serves.
    llm-agents.url = "github:numtide/llm-agents.nix";
    # Prebuilt codex helper binary, pinned by flake.lock; the version in the
    # URL must match llm-agents' codex (asserted in the overlay). See
    # overlays/codex-code-mode-host.nix for why this exists.
    codex-code-mode-host-bin = {
      url = "https://github.com/openai/codex/releases/download/rust-v0.144.0/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          inputs.llm-agents.overlays.default
          # Also override the top-level attrs so anything referencing
          # pkgs.claude-code / pkgs.codex (e.g. wrappers or other apps that
          # launch them) gets the llm-agents version, not the nixpkgs one.
          (final: prev: {
            claude-code = final.llm-agents.claude-code;
          })
          # Per-package fixups on top of the llm-agents packages
          (import ./overlays/codex-code-mode-host.nix inputs)
          (import ./overlays/claude-desktop-keyring.nix)
        ];
      };
      pkgs-bleeding = import inputs.nixpkgs-bleeding {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-bitwarden-zathura = import inputs.nixpkgs-bitwarden-zathura {
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

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-bleeding; inherit pkgs-bitwarden-zathura; inherit pkgs-slow-moving; };
        };

        laptop = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
            ./machines/laptop.nix
          ];

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-bleeding; inherit pkgs-bitwarden-zathura; inherit pkgs-slow-moving; };
        };
      };

      # Export zsh module for reuse in other flakes
      homeManagerModules = {
        sergio-zsh = ./modules/zsh.nix;
      };
    };
}
