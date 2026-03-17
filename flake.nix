{
  description = "Home Manager configuration of admin";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Bleeding edge nixpkgs for latest packages (claude-code, codex, etc.)
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
      url = "github:sergioahp/kitty-extended-keys";
      inputs.nixpkgs.follows = "nixpkgs-slow-moving";
    };
    rofi-switch-rust = {
      url = "github:sergioahp/rofi-switch-rust";
      inputs.nixpkgs.follows = "nixpkgs-slow-moving";
    };
    hyprvoice.url = "github:sergioahp/hyprvoice/feature/custom";
    rofi-power-menu = {
      url = "github:sergioahp/rofi-power-menu";
      flake = false;
    };
    dunst-src = {
      url = "github:sergioahp/dunst/feature/action-history-timeout";
      flake = false;
    };
    status-overlay.url = "github:sergioahp/status-overlay";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-bleeding = import inputs.nixpkgs-bleeding {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-bitwarden-zathura = import inputs.nixpkgs-bitwarden-zathura {
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

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-bleeding; inherit pkgs-bitwarden-zathura; };
        };

        laptop = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
            ./machines/laptop.nix
          ];

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-bleeding; inherit pkgs-bitwarden-zathura; };
        };
      };

      # Export zsh module for reuse in other flakes
      homeManagerModules = {
        sergio-zsh = ./modules/zsh.nix;
      };
    };
}
