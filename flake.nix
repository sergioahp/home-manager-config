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
            # TEMPORARY shim, remove once numtide/llm-agents.nix#6631 lands:
            # their codex package misses the codex-code-mode-host helper that
            # codex >= 0.144.0 spawns for every shell command, breaking all
            # command execution. Upstream ships it prebuilt (static musl), so
            # fetch it and point codex at it via CODEX_CODE_MODE_HOST_PATH
            # instead of recompiling the whole rust workspace. The fetchurl
            # hash pins the host to 0.144.0; when llm-agents bumps codex the
            # URL changes and this fails loudly - check if the shim is still
            # needed before updating the hash.
            codex =
              let
                base = final.llm-agents.codex;
                hostTarball = final.fetchurl {
                  url = "https://github.com/openai/codex/releases/download/rust-v${base.version}/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
                  hash = "sha256-JtnGXFqUfCv0iVE+9/geAnsMltwV4ngd5u7V4CoYmT0=";
                };
                hostBin = final.runCommand "codex-code-mode-host-${base.version}" { } ''
                  mkdir -p $out/bin
                  tar -xzf ${hostTarball} -C $out/bin
                  mv $out/bin/codex-code-mode-host-* $out/bin/codex-code-mode-host
                  chmod +x $out/bin/codex-code-mode-host
                '';
              in
              final.runCommand "codex-with-code-mode-host-${base.version}"
                { nativeBuildInputs = [ final.makeWrapper ]; }
                ''
                  mkdir -p $out/bin
                  for f in ${base}/*; do
                    [ "$(basename "$f")" = bin ] || ln -s "$f" $out/
                  done
                  makeWrapper ${base}/bin/codex $out/bin/codex \
                    --set CODEX_CODE_MODE_HOST_PATH ${hostBin}/bin/codex-code-mode-host
                '';
          })
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
