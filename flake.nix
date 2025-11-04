{
  description = "Home Manager configuration of admin";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    };
    gtk-status-bar.url = "github:sergioahp/gtk-status-bar";
    kitty-extended-keys.url = "github:sergioahp/kitty-extended-keys";
    rofi-switch-rust.url = "github:sergioahp/rofi-switch-rust";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations = {
        nixd = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
            ./machines/nixd.nix
          ];

          extraSpecialArgs = { inherit inputs; inherit system; };
        };

        laptop = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
            ./machines/laptop.nix
          ];

          extraSpecialArgs = { inherit inputs; inherit system; };
        };
      };

      # Export zsh module for reuse in other flakes
      homeManagerModules = {
        sergio-zsh = ./modules/zsh.nix;
      };
    };
}
