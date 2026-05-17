{
  description = "Home Manager configuration of admin";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # hyprland pinned to v0.49.0 (last known stable on desktop)
    # Why tf did you pinned this, claude?
    # last thing that produces a good config != last stable  on desktop
    hyprland.url = "github:hyprwm/Hyprland/v0.49.0";
    # Bleeding edge nixpkgs for latest packages (claude-code, etc.)
    nixpkgs-bleeding.url = "github:nixos/nixpkgs/nixos-unstable";
    codex-src = {
      url = "github:openai/codex";
      flake = false;
    };
    # Slow-moving nixpkgs for packages that are infrequently updated or take too long to update
    # Used for: kitty-extended-keys, nix-rice, rofi-switch-rust (and potentially others to be migrated gradually)
    # Updated manually with: nix flake lock --update-input nixpkgs-slow-moving
    nixpkgs-slow-moving.url = "github:nixos/nixpkgs/nixos-unstable";
    # Known-good nixpkgs snapshot for Firefox transparency.
    # Commit: cc3f2ee0b3909e42334f34720ccac109a7e67068 (2026-04-20T17:14:09Z)
    nixpkgs-firefox-transparent.url = "github:NixOS/nixpkgs/cc3f2ee0b3909e42334f34720ccac109a7e67068";
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
    hyprvoice.url = "github:sergioahp/hyprvoice/feature/context-transcription";
    rofi-power-menu = {
      url = "github:sergioahp/rofi-power-menu";
      flake = false;
    };
    dunst-src = {
      url = "github:sergioahp/dunst/feature/action-history-timeout";
      flake = false;
    };
    status-overlay.url = "github:sergioahp/status-overlay";
    typst-languagetool-nix.url = "github:sergioahp/typst-languagetool-nix";
    fcitx5-fzf-table = {
      url = "github:sergioahp/fcitx5-fzf-table";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      codexRoot = inputs.codex-src + "/codex-rs";
      codexCargoToml = builtins.fromTOML (builtins.readFile (codexRoot + "/Cargo.toml"));
      codexCargoVersion = codexCargoToml.workspace.package.version;
      codexVersion =
        if codexCargoVersion != "0.0.0" then codexCargoVersion else "0.0.0-dev";
      codexNixpkgsDir = inputs.nixpkgs-bleeding.outPath + "/pkgs/by-name/co/codex";
      codexFetchers = pkgs-bleeding.callPackage (codexNixpkgsDir + "/fetchers.nix") { };
      codex = pkgs-bleeding.callPackage (
        {
          lib,
          stdenv,
          callPackage,
          rustPlatform,
          installShellFiles,
          bubblewrap,
          clang,
          cmake,
          gitMinimal,
          libcap,
          libclang,
          librusty_v8 ? callPackage (codexNixpkgsDir + "/librusty_v8.nix") {
            inherit (codexFetchers) fetchLibrustyV8;
          },
          livekit-libwebrtc,
          makeBinaryWrapper,
          pkg-config,
          openssl,
          ripgrep,
          versionCheckHook,
          installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
        }:
        rustPlatform.buildRustPackage {
          pname = "codex";
          version = codexVersion;

          src = inputs.codex-src;
          sourceRoot = "source/codex-rs";

          cargoLock = {
            lockFile = codexRoot + "/Cargo.lock";
            allowBuiltinFetchGit = true;
          };

          cargoBuildFlags = [
            "--package"
            "codex-cli"
          ];
          cargoCheckFlags = [
            "--package"
            "codex-cli"
          ];

          postPatch = ''
            # nixpkgs ships libwebrtc as a shared library, so patch the crate
            # build script to link it dynamically.
            find "$cargoDepsCopy" -path '*/webrtc-sys-*/build.rs' \
              -exec sed -i 's/cargo:rustc-link-lib=static=webrtc/cargo:rustc-link-lib=dylib=webrtc/' {} +

            substituteInPlace Cargo.toml \
              --replace-fail 'lto = "fat"' "" \
              --replace-fail 'codegen-units = 1' "" \
              --replace-fail 'version = "0.0.0"' 'version = "${codexVersion}"'
          '';

          nativeBuildInputs = [
            clang
            cmake
            gitMinimal
            installShellFiles
            makeBinaryWrapper
            pkg-config
          ];

          buildInputs = [
            libclang
            openssl
          ]
          ++ lib.optionals stdenv.hostPlatform.isLinux [
            libcap
          ];

          env = {
            LIBCLANG_PATH = "${lib.getLib libclang}/lib";
            LK_CUSTOM_WEBRTC = lib.getDev livekit-libwebrtc;
            NIX_CFLAGS_COMPILE = toString (
              lib.optionals stdenv.cc.isGNU [
                "-Wno-error=stringop-overflow"
              ]
              ++ lib.optionals stdenv.cc.isClang [
                "-Wno-error=character-conversion"
              ]
            );
            RUSTY_V8_ARCHIVE = librusty_v8;
          };

          doCheck = false;

          postInstall = lib.optionalString installShellCompletions ''
            installShellCompletion --cmd codex \
              --bash <($out/bin/codex completion bash) \
              --fish <($out/bin/codex completion fish) \
              --zsh <($out/bin/codex completion zsh)
          '';

          postFixup = ''
            wrapProgram $out/bin/codex --prefix PATH : ${
              lib.makeBinPath ([ ripgrep ] ++ lib.optionals stdenv.hostPlatform.isLinux [ bubblewrap ])
            }
          '';

          doInstallCheck = true;
          nativeInstallCheckInputs = [ versionCheckHook ];

          meta = {
            description = "Lightweight coding agent that runs in your terminal";
            homepage = "https://github.com/openai/codex";
            license = lib.licenses.asl20;
            mainProgram = "codex";
            platforms = lib.platforms.unix;
          };
        }
      ) { };
    in {
      homeConfigurations = {
        nixd = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
            ./machines/nixd.nix
          ];

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-bleeding; inherit pkgs-bitwarden-zathura; inherit codex; };
        };

        laptop = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
            ./machines/laptop.nix
          ];

          extraSpecialArgs = { inherit inputs; inherit system; inherit pkgs-bleeding; inherit pkgs-bitwarden-zathura; inherit codex; };
        };
      };

      # Export zsh module for reuse in other flakes
      homeManagerModules = {
        sergio-zsh = ./modules/zsh.nix;
      };
    };
}
