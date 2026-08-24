# nixpkgs / home-manager Update Analysis

Written 2026-08-23, before bumping the main inputs of this flake.

## TL;DR - Quick Summary

**Scope:** `nixpkgs` 61b7c44 (2026-07-18) -> 2c423e0 (2026-08-22), the rev the
NixOS side already runs, and `home-manager` 3139deb (2026-07-19) -> cfba7ad
(2026-08-23). Both home-manager revs target release 26.11, so this is not a
release-branch jump.

**One hard blocker:** `layan-gtk-theme` was removed from nixpkgs. The switch
fails at evaluation, before anything builds.

**Everything else resolves.** A dry run with only those two inputs overridden
completes: 148 derivations to build, 907 paths to fetch, 4.8 GiB download /
16.6 GiB unpacked. The local builds are the usual suspects (forked rofi and
dunst, nsxiv with its baked conf, the pylsp-mypy and sage overrides); nothing
heavy compiles from scratch.

## The blocker

```
error: 'layan-gtk-theme' has been removed because it depended on
'gtk-engine-murrine', which was removed because it was unmaintained upstream
and depended on GTK 2.
```

Used at `home.nix:333` (`gtk.theme.package`) and named again at `home.nix:332`
and `home.nix:373` (`GTK_THEME = "Layan-Dark"`). The same murrine purge removed
`graphite-gtk-theme`, `materia-theme`, `flat-remix-gtk` and `numix-gtk-theme`.
GTK 2 itself is still in nixpkgs; only the engine went, so `qt.platformTheme`
= gtk2 and `libsForQt5.qtstyleplugins` are unaffected.

Still present: `adw-gtk3`, `orchis-theme`, `colloid-gtk-theme`, `arc-theme`,
`catppuccin-gtk`, `gruvbox-gtk-theme`, `fluent-gtk-theme`,
`whitesur-gtk-theme`, `nordic`, `qogir-theme`.

Two ways out:

1. **Pin it, the way bitwarden and zathura already are.** Both
   `nixpkgs-slow-moving` (2026-02-17) and `nixpkgs-bitwarden-zathura`
   (2025-06-18) still carry `layan-gtk-theme-2023-05-23`, so this needs no new
   input, just another `inherit (pinnedApps)` style line. murrine is a GTK 2
   engine, so its absence does not affect the GTK 3 and GTK 4 stylesheets this
   config actually uses.
2. **Move to a surviving theme.** Orchis and Colloid are by the same author as
   Layan and are the closest visual match.

Verified by re-running the dry run with the theme swapped: it then completes
with no further evaluation errors.

## Not a problem, checked

- **home-manager news in the window.** Only two removals, `programs.hexchat`
  and `programs.animdl`; neither is used here. The claude-code plugin manifest
  rename (`claude-code-home-manager` -> `hm`) does not apply, because this
  config takes claude-code as a package through the llm-agents overlay rather
  than through the home-manager module. The new `%YAML 1.1` document header on
  generated YAML does not apply either; the only YAML here is the hand-written
  sops secrets file.
- **Option renames and removals.** Diffing the two home-manager trees for
  `mkRenamedOptionModule` / `mkRemovedOptionModule` turns up nothing this
  config touches beyond those two modules.
- **Qt side.** `libsForQt5.qtstyleplugins`, `adwaita-qt`, `adwaita-qt6`,
  `gtk2`, `capitaine-cursors` all survive.

## Worth deciding before the switch

- **hyprland version skew.** The profile carries 0.55.4 while the compositor
  is the system's 0.56.2, and `~/.nix-profile/bin` sits ahead of
  `/run/current-system/sw/bin` on PATH, so `hyprctl`, `hyprpm` and
  `start-hyprland` on the shell PATH are the 0.55.4 copies talking to a 0.56.2
  socket. The update aligns them. HYPRLAND_CRASH_ANALYSIS.md already tracks
  this as "profile copy only"; the compositor-side risk was taken when
  `~/nixos` moved to 0.56.2.
- **`home.pointerCursor` deprecation.** Already warning on every build:
  "Relying on `home.pointerCursor` to enable cursor config generation is
  deprecated. Please update your configuration to explicitly set
  `home.pointerCursor.enable = true`." Cheap to clear while touching the file.
- **session-desktop.** The comment at `home.nix:185` says it is broken on the
  current pin. In the newer nixpkgs it is now `meta.broken = true` outright, so
  the `pkgs-slow-moving` route stays and the comment could say so.
- **pylsp-mypy overlay.** Marked TEMPORARY. mypy is 2.1.0 and pylsp-mypy 0.7.0
  in both revs, so the version skew that breaks the test suite has not moved.
  The `doCheck = false` override stays.
- **nixpkgs-bleeding.** Locked at 2026-08-10, which is older than the proposed
  main pin. After the update "bleeding" would be behind "stable". It exists
  only for `opencode`, so either bump it in the same pass or retire it.
- **sops-nix.** Locked at 2025-04-07 and set to `follows` nixpkgs, so a
  16-month-old flake would be evaluated against a fresh nixpkgs. It resolves in
  the dry run (`sops-install-secrets` builds), but it is the oldest thing
  riding on this input.

## Version moves that will be visible

```
ffmpeg               8.1.2        -> 9.0          (major; obs-studio, yt-dlp, imagemagick)
libreoffice          25.8.5.2     -> 26.2.5.2     (major)
firefox              152.0.6      -> 154.0
thunderbird          152.0.1      -> 153.0.3
hyprland             0.55.4       -> 0.56.2       (profile copy only)
nil                  2025-06-13   -> 2026-07-23   (a year of the nix LSP)
rust-analyzer        2026-06-15   -> 2026-08-03
lua-language-server  3.18.2       -> 3.19.1
vscodium-fhs         1.121.03429  -> 1.126.04524
gcc                  15.2.0       -> 15.3.0
python3              3.14.6       -> 3.14.7
mesa                 26.1.5       -> 26.2.1
fontconfig           2.18.1       -> 2.18.2
brave / discord / element-desktop / tor-browser / mullvad-browser / yt-dlp / wireshark / bitwarden-desktop all move
```

`kitty` is not on that list on purpose: the overlay replaces `pkgs.kitty` with
the `kitty-extended-keys` input, which follows `nixpkgs-slow-moving`, so the
terminal stays where it is.

## Suggested order

1. Resolve the Layan theme, pin or replace.
2. Set `home.pointerCursor.enable = true`.
3. `nix flake update nixpkgs home-manager`, leaving the deliberately frozen
   inputs (`nixpkgs-slow-moving`, `nixpkgs-bitwarden-zathura`, `nix-rice`,
   `hyprswitch`) alone.
4. `home-manager build --flake '.?submodules=1#nixd'` before switching. The
   previous generation stays available for rollback either way.

## Method

- Input ages read out of `flake.lock` against the resolved root inputs.
- Version table produced by importing both nixpkgs trees out of the store and
  diffing `.version` over the attributes this config installs
  (`tmp/nixpkgs-delta/versions.nix`).
- Removals and breakage found with
  `nix build --dry-run '.?submodules=1#homeConfigurations.nixd.activationPackage'`
  plus `--override-input` for nixpkgs and home-manager only, so every other
  input stayed at its locked rev. No lock file was written.
- home-manager news diffed by fetching both source trees and comparing
  `modules/misc/news/`.
