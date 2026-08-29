{ config, lib, pkgs, inputs, system, ... }:
let
  cfg = config.programs.sergio-xremap;
  clipboardDragonDrop = pkgs.writeShellApplication {
    name = "clipboard-dragon-drop";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dragon-drop
      (lib.getBin pkgs.glib)
      pkgs.libnotify
      pkgs.wl-clipboard
    ];
    text = ''
      notify_failure() {
        notify-send \
          --app-name="clipboard-dragon-drop" \
          --urgency=normal \
          "DragonDrop" \
          "$1" >/dev/null 2>&1 || true
      }

      if ! clipboard_types="$(wl-paste --list-types 2>/dev/null)" ||
         [[ -z $clipboard_types ]]; then
        notify_failure "The clipboard is empty or unavailable."
        exit 1
      fi

      has_type() {
        local requested=$1
        local advertised

        while IFS= read -r advertised; do
          [[ $advertised == "$requested" ]] && return 0
        done <<< "$clipboard_types"
        return 1
      }

      content_type=
      for candidate in text/uri-list x-special/gnome-copied-files; do
        if has_type "$candidate"; then
          content_type=$candidate
          break
        fi
      done

      image_extension=
      if [[ -z $content_type ]]; then
        while IFS= read -r advertised; do
          case "$advertised" in
            image/png) image_extension=png ;;
            image/jpeg | image/jpg) image_extension=jpg ;;
            image/webp) image_extension=webp ;;
            image/gif) image_extension=gif ;;
            image/bmp) image_extension=bmp ;;
            image/tiff) image_extension=tiff ;;
            image/avif) image_extension=avif ;;
            image/svg+xml) image_extension=svg ;;
            *) continue ;;
          esac
          content_type=$advertised
          break
        done <<< "$clipboard_types"
      fi

      if [[ -z $content_type ]]; then
        for candidate in text/plain\;charset=utf-8 text/plain UTF8_STRING STRING; do
          if has_type "$candidate"; then
            content_type=$candidate
            break
          fi
        done
      fi

      items=()
      temporary_file=
      cleanup() {
        [[ -z $temporary_file ]] || rm -f -- "$temporary_file"
      }
      trap cleanup EXIT

      if [[ -n $image_extension ]]; then
        temporary_root="''${XDG_RUNTIME_DIR:-''${XDG_CACHE_HOME:-$HOME/.cache}}/clipboard-dragon-drop"
        mkdir -p -- "$temporary_root"
        chmod 700 -- "$temporary_root"
        temporary_file="$(mktemp "$temporary_root/clipboard.XXXXXX.$image_extension")"
        if ! wl-paste --type "$content_type" > "$temporary_file" ||
           [[ ! -s $temporary_file ]]; then
          notify_failure "The clipboard image could not be read."
          exit 1
        fi
        items+=("$temporary_file")
      elif [[ -n $content_type ]]; then
        if ! clipboard_text="$(wl-paste --no-newline --type "$content_type" 2>/dev/null)"; then
          notify_failure "The clipboard contents could not be read."
          exit 1
        fi

        while IFS= read -r item || [[ -n $item ]]; do
          item="''${item%$'\r'}"
          [[ -z $item || $item == \#* || $item == copy || $item == cut ]] && continue

          if [[ $item == \~/* ]]; then
            item="$HOME/''${item:2}"
          fi

          if [[ -e $item ]]; then
            items+=("$(realpath --canonicalize-existing -- "$item")")
          elif [[ $item == file:* ]]; then
            if ! gio info -- "$item" >/dev/null 2>&1; then
              notify_failure "The clipboard refers to a file that no longer exists."
              exit 1
            fi
            items+=("$item")
          elif [[ $item =~ ^[A-Za-z][A-Za-z0-9+.-]*: ]]; then
            items+=("$item")
          else
            notify_failure "The clipboard is not a list of files or valid URIs."
            exit 1
          fi
        done <<< "$clipboard_text"
      fi

      if (( ''${#items[@]} == 0 )); then
        notify_failure "The clipboard does not contain a file, URI, or image DragonDrop can open."
        exit 1
      fi

      if ! dragon-drop "''${items[@]}"; then
        notify_failure "DragonDrop could not open the clipboard contents."
        exit 1
      fi
    '';
  };
  clipboardDragonDropLaunch = [
    "${pkgs.uwsm}/bin/uwsm-app" "--"
    "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
    "${clipboardDragonDrop}/bin/clipboard-dragon-drop"
  ];
  # Select a region and copy its text to the clipboard.
  ocrRegion = pkgs.writeShellApplication {
    name = "ocr-region";
    runtimeInputs = [
      config.programs.ocr.package
      config.wayland.windowManager.hyprland.package
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.grim
      pkgs.hyprpicker
      pkgs.libnotify
      pkgs.slurp
    ];
    text = ''
      notify() {
        notify-send --app-name=ocr --urgency=normal "OCR" "$1" >/dev/null 2>&1 || true
      }

      # Freeze the screen so selection and capture use the same image.
      hyprpicker -r -z &
      picker=$!
      unfreeze() { kill "$picker" 2>/dev/null || true; }
      trap unfreeze EXIT

      # Wait for the frozen layer surface before capturing.
      ready=
      deadline=$(($(date +%s%3N) + 200))
      while [ "$(date +%s%3N)" -lt "$deadline" ]; do
        kill -0 "$picker" 2>/dev/null || break
        if hyprctl layers -j | grep -q '"namespace": "hyprpicker"'; then
          ready=1
          break
        fi
        sleep 0.01
      done
      [ -n "$ready" ] || { notify "The screen could not be frozen."; exit 1; }

      geometry="$(slurp -w 0)" || exit 1

      # Let recognition run after unfreezing.
      if ! text="$( { grim -g "$geometry" -; unfreeze; } | ocr --copy - )"; then
        notify "The selection could not be recognised."
        exit 1
      fi

      [ -n "$text" ] || { notify "No text in the selection."; exit 0; }
      notify "$text"
    '';
  };
  ocrRegionLaunch = [ "${ocrRegion}/bin/ocr-region" ];
  launcher = import ./rofi-launcher.nix {
    inherit config pkgs lib inputs system clipboardDragonDropLaunch ocrRegionLaunch;
  };
  launcherBin = "${launcher.script}/bin/xremap-launcher";
  rofiPowerMenu = "${inputs.rofi-power-menu}/rofi-power-menu";

  # Mirror of rofiSwitcher in rofi-launcher.nix: ensure quick-start uses the
  # overlay's forked rofi (MM_FZF) instead of the one compile-baked by the
  # rofi-switch-rust flake's own nixpkgs.
  rofiSwitcher = pkgs.writeShellScriptBin "quick-start" ''
    export ROFI_BIN=${pkgs.rofi}/bin/rofi
    exec ${inputs.rofi-switch-rust.packages.${system}.default}/bin/quick-start "$@"
  '';
in {
  # -----------------------------------------------------------------------------
  # xremap launcher metadata guide
  #
  # Dear future assistant (human or chatbot):
  #
  # This module is the single source of truth for which key bindings feed the
  # rofi-based xremap launcher. Each binding is annotated with a comment that
  # starts with `# rofi-entry`.
  #
  # Comment syntax:
  #   # rofi-entry <decision> [key=value ...]
  #
  # Decisions:
  #   - `include`  → binding should appear in the launcher
  #   - `skip`     → binding is excluded; provide a `reason=...`
  #
  # Attributes (key=value) give presentation hints consumed manually by the
  # launcher generator. Expected keys:
  #   * category : logical group (“Applications”, “Window”, “Audio”, …)
  #   * color    : hex color string matching the rofi palette
  #   * emoji    : UTF-8 glyph rendered in the first column (avoid VS-16/ZWJ)
  #
  # Rules for editing:
  #   1. Keep every binding comment directly above the binding it describes.
  #   2. When adding new bindings that should appear in the launcher, add
  #      `include` metadata with category, color, and emoji. Choose emoji that
  #      fits the action and prefer simple single-codepoint symbols (no VS-16).
  #   3. When excluding bindings, use `skip` with a short `reason` (“submap”,
  #      “workspace-switch”, etc.) so automated tooling or reviewers know why.
  #   4. Do not remove existing metadata without updating the launcher entries
  #      inside `modules/rofi-launcher.nix`. The launcher still assembles its
  #      entry list manually; these comments are guard rails, not automation.
  #   5. If you change the comment schema, update this guide and the generator.
  #
  # The rofi launcher itself is defined in `modules/rofi-launcher.nix`. Any new
  # binding marked `include` must be mirrored there manually; we deliberately
  # choose chatbot-guided upkeep over building a parser for a superset of this
  # config (been there, tried that, not worth the complexity). Treat these
  # comments as the contract between the configuration and the launcher script.
  # -----------------------------------------------------------------------------
  imports = [];
  options = {
    programs.sergio-xremap.enable = lib.mkEnableOption "sergio's xremap configuration";
  };
  config = lib.mkIf cfg.enable {
    services.xremap = {
      enable = true;
      withHypr = true;
      config = {
        keypress_delay_ms = 20;
        modmap = [
          {
            name = "main modmaps";
            remap = {
              shift_r = "alt_l";
            };
          }
        ];
        keymap = [
          # Kitty hyprvoice-context override (must precede "main remaps" - see note).
          #
          # Globally, super-dot>super-dot runs `hyprvoice toggle` directly with no
          # terminal context. Inside kitty we instead synthesize the ctrl+. ctrl+.
          # chord that kitty's own config (in the kitty-extended-keys flake) binds to
          #   launch --stdin-source=@screen_scrollback ... hyprvoice toggle
          # so the transcription model receives the visible scrollback as context.
          # The muscle-memory super-dot stays the same; only the focused app changes
          # whether scrollback is attached.
          #
          # Precedence: xremap gathers every keymap binding `super-dot` in config
          # order and MERGES the nested submaps; at each leaf the FIRST matching entry
          # wins (see find_keymap in xremap's event_handler.rs). This block must
          # therefore sit ahead of "main remaps" so its leaves shadow the global ones
          # while kitty is focused. `application.only = "kitty"` makes it inert
          # everywhere else, so the direct-toggle global binding still applies there.
          {
            name = "kitty hyprvoice context remaps";
            remap = {
              # rofi-entry skip reason=application-remap
              super-dot = {
                remap = {
                  # rofi-entry skip reason=application-remap
                  # Emit kitty's ctrl+. ctrl+. chord -> records with scrollback context
                  super-dot = [ "c-dot" "c-dot" ];
                  # rofi-entry skip reason=application-remap
                  # Cancel needs no terminal context; call hyprvoice like the global bind
                  super-c = {
                    launch = [ "${inputs.hyprvoice.packages.${system}.default}/bin/hyprvoice" "cancel" ];
                  };
                };
              };
            };
            application = {
              "only" = "kitty";
            };
          }
          {
            name = "main remaps";
            remap = {
              # rofi-entry skip reason=submap
              super-m = {
                remap = {
                  # rofi-entry include category=Applications color=#7AA2F7 emoji=🖥️
                  super-l = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm-app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.kitty}/bin/kitty"
                    ];
                  };
                  # rofi-entry include category=Applications color=#7AA2F7 emoji=🦊
                  super-f = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm-app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.firefox}/bin/firefox"
                    ];
                  };
                  # rofi-entry include category=Utilities color=#7DCFFF emoji=🗂️
                  super-e = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm-app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.kitty}/bin/kitty"
                      "${pkgs.yazi}/bin/yazi"
                    ];
                  };
                  # rofi-entry include category=Monitoring color=#9ECE6A emoji=📊
                  super-o = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm-app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.kitty}/bin/kitty"
                      "${pkgs.btop}/bin/btop"
                    ];
                  };
                  # rofi-entry include category=Applications color=#7AA2F7 emoji=🚀
                  super-m = {
                    launch = [
                      # bug: hyprctl does not work with commands containing semicolons
                      # Rofi launches instantly (no uwsm overhead), but apps it spawns get uwsm-app + hyprctl
                      # Wraps launched apps for session management and workspace stability.
                      # drun ignores -run-command and launches via GIO as a child of rofi
                      # (hence of xremap.service), so apps died on every xremap restart. The
                      # forked rofi's -drun-launch-prefix routes the launch through
                      # uwsm/hyprctl instead, detaching it into the compositor's scope.
                      "${pkgs.rofi}/bin/rofi" "-show" "drun"
                      "-drun-launch-prefix" "${pkgs.uwsm}/bin/uwsm-app -- ${pkgs.hyprland}/bin/hyprctl dispatch exec --"
                      "-theme-str" "window {width: 20%;}"
                    ];
                  };
                  # rofi-entry include category=Utilities color=#7DCFFF emoji=⚡
                  super-k = {
                    launch = [
                      "${rofiSwitcher}/bin/quick-start"
                    ];
                  };
                  # rofi-entry include category=Applications color=#7AA2F7 emoji=🔐
                  super-i = {
                    launch = [
                      "${pkgs.uwsm}/bin/uwsm-app" "--"
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch" "--" "exec"
                      "${pkgs.bitwarden-desktop}/bin/bitwarden"
                    ];
                  };
                  # rofi-entry include category=Utilities color=#7DCFFF emoji=⏻
                  super-p = {
                    launch = [
                      "${pkgs.rofi}/bin/rofi"
                      "-show"
                      "power-menu"
                      "-modi"
                      "power-menu:${rofiPowerMenu}"
                    ];
                  };
                };
              };
              # rofi-entry skip reason=submap
              super-s = {
                remap = {
                  # rofi-entry include category=Utilities color=#7DCFFF emoji=🖼️
                  super-e = {
                    launch = [
                      "${pkgs.bash}/bin/sh" "-c"
                      ''
                        ${pkgs.wl-clipboard}/bin/wl-paste --type image/png |
                        ${pkgs.swappy}/bin/swappy -f -
                      ''
                    ];
                  };
                  # rofi-entry include category=Utilities color=#7DCFFF emoji=📸
                  super-d = {
                    launch = [
                      "${pkgs.bash}/bin/sh" "-c"
                      ''
                        # Freeze the screen with hyprpicker (-r renders a still
                        # frame, -z drops the zoom lens) so the slurp selection
                        # and the grim capture both see a frozen image. Capture
                        # to a private temp file and kill hyprpicker before
                        # swappy opens, otherwise the frozen overlay would linger
                        # on top of the editor (swappy -f blocks until you close
                        # it).
                        ${pkgs.hyprpicker}/bin/hyprpicker -r -z &
                        picker=$!
                        # hyprpicker captures and commits its frozen overlay
                        # asynchronously, so poll for the layer-surface instead
                        # of a blind sleep: wait at most 200ms, bail if the
                        # process dies or the overlay never shows (otherwise grim
                        # would grab the live desktop), and proceed the instant
                        # it is up.
                        ready=
                        deadline=$(($(${pkgs.coreutils}/bin/date +%s%3N) + 200))
                        while [ "$(${pkgs.coreutils}/bin/date +%s%3N)" -lt "$deadline" ]; do
                          kill -0 "$picker" 2>/dev/null || break
                          if ${config.wayland.windowManager.hyprland.package}/bin/hyprctl layers -j |
                               ${pkgs.gnugrep}/bin/grep -q '"namespace": "hyprpicker"'; then
                            ready=1
                            break
                          fi
                          ${pkgs.coreutils}/bin/sleep 0.01
                        done
                        [ -n "$ready" ] || { kill "$picker" 2>/dev/null; exit 1; }
                        geometry="$(${pkgs.slurp}/bin/slurp -w 0)" || { kill "$picker"; exit 1; }
                        shot="$(${pkgs.coreutils}/bin/mktemp --tmpdir="''${XDG_RUNTIME_DIR:-/tmp}" shot.XXXXXX.png)"
                        ${pkgs.grim}/bin/grim -g "$geometry" "$shot"
                        kill "$picker"
                        ${pkgs.swappy}/bin/swappy -f "$shot"
                        ${pkgs.coreutils}/bin/rm -f "$shot"
                      ''
                    ];
                  };
                  # rofi-entry include category=Utilities color=#7DCFFF emoji=🔤
                  super-r = {
                    launch = ocrRegionLaunch;
                  };
                  # rofi-entry include category=Monitoring color=#9ECE6A emoji=🟠
                  super-o = {
                    launch = [
                      "${inputs.status-overlay.packages.${system}.default}/bin/status-overlay"
                      "toggle"
                    ];
                  };
                  # rofi-entry include category=Utilities color=#7DCFFF emoji=🎨
                  super-c = {
                    launch = [ "${pkgs.hyprpicker}/bin/hyprpicker" "-a" ];
                  };
                  # rofi-entry include category=Utilities color=#7DCFFF emoji=🐉
                  super-b = {
                    launch = clipboardDragonDropLaunch;
                  };
                };
              };
              # rofi-entry skip reason=submap
              super-u = {
                remap = {
                  # rofi-entry include category=Notifications color=#F7768E emoji=🕰️
                  super-f = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "history-pop" ];
                  };
                  # rofi-entry include category=Notifications color=#F7768E emoji=❌
                  super-d = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "close" ];
                  };
                  # rofi-entry include category=Notifications color=#F7768E emoji=🧹
                  super-s = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "close-all" ];
                  };
                  # rofi-entry include category=Notifications color=#F7768E emoji=🎯
                  super-c = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "action" ];
                  };
                  # rofi-entry include category=Notifications color=#F7768E emoji=🛠️
                  super-e = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "context" ];
                  };
                  # rofi-entry include category=Notifications color=#F7768E emoji=⏯️
                  super-t = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "set-paused" "toggle" ];
                  };
                  # rofi-entry include category=Notifications color=#F7768E emoji=⏸️
                  super-i = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "set-paused" "true" ];
                  };
                  # rofi-entry include category=Notifications color=#F7768E emoji=▶️
                  super-o = {
                    launch = [ "${pkgs.dunst}/bin/dunstctl" "set-paused" "false" ];
                  };
                };
              };
              # rofi-entry skip reason=submap
              super-r = {
                remap = {
                  # rofi-entry include category=Input color=#7DCFFF emoji=あ
                  super-j = {
                    launch = [ "${pkgs.fcitx5}/bin/fcitx5-remote" "-s" "mozc" ];
                  };
                  # rofi-entry include category=Input color=#7DCFFF emoji=☺
                  super-k = {
                    launch = [ "${pkgs.fcitx5}/bin/fcitx5-remote" "-s" "fzf-kaomoji" ];
                  };
                  # rofi-entry include category=Input color=#7DCFFF emoji=λ
                  super-l = {
                    launch = [ "${pkgs.fcitx5}/bin/fcitx5-remote" "-s" "fzf-latex" ];
                  };
                  # rofi-entry include category=Input color=#7DCFFF emoji=T
                  super-t = {
                    launch = [ "${pkgs.fcitx5}/bin/fcitx5-remote" "-s" "fzf-typst" ];
                  };
                  # rofi-entry include category=Input color=#7DCFFF emoji=ə
                  super-i = {
                    launch = [ "${pkgs.fcitx5}/bin/fcitx5-remote" "-s" "fzf-ipa" ];
                  };
                  # rofi-entry include category=Input color=#7DCFFF emoji=😀
                  # Pokes the fcitx5-fzf-picker Module addon directly over
                  # D-Bus. Synthesized keys aren't reliable here because the
                  # synth -> compositor -> focused-app -> wayland-IM hop only
                  # delivers to fcitx5 if the focused app speaks the IM
                  # protocol; a D-Bus call is addon-to-addon and skips all of
                  # that. The picker pops a one-shot candidate list on top of
                  # the current IM instead of swapping IMs like the siblings.
                  super-m = {
                    launch = [
                      "${pkgs.dbus}/bin/dbus-send"
                      "--session" "--type=method_call"
                      "--dest=org.fcitx.Fcitx5"
                      "/fzfpicker"
                      "org.fcitx.Fcitx5.Addon.FzfPicker1.TriggerEmoji"
                    ];
                  };
                  # rofi-entry include category=Input color=#7DCFFF emoji=📋
                  # Clipboard fuzzy picker - sibling of fzfpicker, pokes the
                  # fcitx5-fzf-clipboard addon over D-Bus. Same one-off shape:
                  # pop, type to filter, Alt+1..0 to commit, Esc to cancel.
                  super-o = {
                    launch = [
                      "${pkgs.dbus}/bin/dbus-send"
                      "--session" "--type=method_call"
                      "--dest=org.fcitx.Fcitx5"
                      "/fzfclipboard"
                      "org.fcitx.Fcitx5.Addon.FzfClipboard1.Trigger"
                    ];
                  };
                  # rofi-entry include category=Input color=#7DCFFF emoji=🧹
                  # Drop the most recent clipboard history entry. Use after
                  # copying something you didn't want recorded (the OS
                  # clipboard itself is unaffected; bind wl-copy --clear
                  # separately if you also need that).
                  super-p = {
                    launch = [
                      "${pkgs.dbus}/bin/dbus-send"
                      "--session" "--type=method_call"
                      "--dest=org.fcitx.Fcitx5"
                      "/fzfclipboard"
                      "org.fcitx.Fcitx5.Addon.FzfClipboard1.ClearLast"
                    ];
                  };
                  # rofi-entry include category=Input color=#7DCFFF emoji=⌨
                  super-r = {
                    launch = [ "${pkgs.fcitx5}/bin/fcitx5-remote" "-s" "keyboard-us-altgr-intl" ];
                  };
                };
              };
              # rofi-entry skip reason=workspace-switch
              super-f = {
                remap = {
                  # rofi-entry skip reason=workspace-switch
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "1"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-i = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "2"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-o = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "3"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "4"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "5"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "6"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-l = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "7"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-semicolon = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "8"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-m = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "9"];
                  };
                  # rofi-entry skip reason=workspace-switch
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "workspace" "10"];
                  };
                };
              };
              # rofi-entry skip reason=workspace-move
              super-e = {
                remap = {
                  # rofi-entry skip reason=workspace-move
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "1"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-i = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "2"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-o = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "3"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "4"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "5"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "6"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-l = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "7"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-semicolon = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "8"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-m = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "9"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspacesilent" "10"];
                  };
                };
              };
              # rofi-entry skip reason=workspace-move
              super-v = {
                remap = {
                  # rofi-entry skip reason=workspace-move
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "1"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-i = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "2"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-o = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "3"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "4"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "5"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "6"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-l = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "7"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-semicolon = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "8"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-m = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "9"];
                  };
                  # rofi-entry skip reason=workspace-move
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movetoworkspace" "10"];
                  };
                };
              };

              # rofi-entry skip reason=submap
              super-d = {
                remap = {
                  # rofi-entry include category=Window color=#BB9AF7 emoji=💀
                  super-c = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "killactive" ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=🔁
                  super-j = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "swapnext" ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=↩️
                  super-k = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "swapnext" "prev" ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=🪟
                  super-u = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "togglefloating" ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=🔳
                  super-f = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "fullscreen" ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=🟥
                  super-comma = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "fullscreenstate" "1" ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=📺
                  super-m = {
                    launch = [
                      "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                      "movewindow" "mon:+1"
                    ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=🔄
                  super-p = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "swapactiveworkspaces" "0" "1" ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=🪚
                  super-t = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "layoutmsg" "togglesplit" ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=🚨
                  super-g = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "focusurgentorlast" ];
                  };
                  # rofi-entry include category=Window color=#BB9AF7 emoji=🧱
                  super-s = {
                    launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                    "layoutmsg" "swapsplit" ];
                  };
                };
              };

              # rofi-entry include category=Window color=#BB9AF7 emoji=🪟
              super-comma = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "focusmonitor" "+1" ];
              };

              # rofi-entry include category=Window color=#BB9AF7 emoji=➡️
              # batch raises the newly focused window so floating clients
              # don't stay buried behind their siblings
              super-j = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "--batch"
                "dispatch cyclenext; dispatch alterzorder top,activewindow" ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=⬅️
              super-k = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "--batch"
                "dispatch cyclenext prev; dispatch alterzorder top,activewindow" ];
              };
              # rofi-entry skip reason=submap
              super-slash = {
                remap = {
                  # rofi-entry skip reason=launcher-self
                  super-slash = {
                    launch = [ launcherBin ];
                  };
                };
              };
              # rofi-entry skip reason=submap
              super-dot = {
                remap = {
                  # rofi-entry include category=Productivity color=#7AA2F7 emoji=🎤
                  super-dot = {
                    launch = [ "${inputs.hyprvoice.packages.${system}.default}/bin/hyprvoice" "toggle" ];
                  };
                  # rofi-entry include category=Productivity color=#7AA2F7 emoji=❌
                  super-c = {
                    launch = [ "${inputs.hyprvoice.packages.${system}.default}/bin/hyprvoice" "cancel" ];
                  };
                };
              };
              # Tray keyboard navigation: press super+[ twice to grab the
              # keyboard and focus the tray at level 0. `open` resumes on the
              # icon the last session ended on (first icon on a fresh bar or if
              # that icon is gone), so it is not pinned to any one tray app. h/l
              # move across the tray icons (each landed icon auto-opens its
              # dropdown); j/k descend into the open dropdown; inside it h/l step
              # through submenus and gg/G jump; Enter activates; q/Escape steps
              # out one level, so pressing it again at level 0 releases the grab.
              # Uses the packaged trayctl from the gtk-status-bar flake input.
              # rofi-entry skip reason=submap
              super-leftbrace = {
                remap = {
                  # rofi-entry skip reason=submap-self
                  super-leftbrace = {
                    launch = [
                      "${inputs.gtk-status-bar.packages.${system}.default}/bin/trayctl"
                      "open"
                    ];
                  };
                };
              };
              # rofi-entry skip reason=workspace-relative
              super-n = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "workspace" "r+1"];
              };
              # rofi-entry skip reason=workspace-relative
              super-p = {
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "workspace" "r-1" ];
              };
              # rofi-entry skip reason=workspace-previous
              super-semicolon = {
                # Seems this cannot be configured to work with empty workspaces
                # also
                launch = [ "${pkgs.hyprland}/bin/hyprctl" "dispatch"
                "workspace" "previous_per_monitor" ];
              };
              # rofi-entry skip reason=submap
              super-y = {
                remap = {
              # rofi-entry include category=Media color=#E0AF68 emoji=⏯️
                    super-s = {
                      launch = [ "${pkgs.playerctl}/bin/playerctl" "play-pause" ];
                  };
                    # rofi-entry include category=Media color=#E0AF68 emoji=⏭️
                    super-d = {
                      launch = [ "${pkgs.playerctl}/bin/playerctl" "next" ];
                  };
                    # rofi-entry include category=Media color=#E0AF68 emoji=⏮️
                    super-f = {
                      launch = [ "${pkgs.playerctl}/bin/playerctl" "previous" ];
                  };
                    # rofi-entry include category=Audio color=#2AC3DE emoji=🔇
                    super-e = {
                      launch = [ "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@"
                                        "toggle" ];
                  };
                };
              };
              # rofi-entry include category=Audio color=#2AC3DE emoji=🔉
              super-i = {
                launch = [ "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@"
                  "5%-" ];
              };
              # rofi-entry include category=Audio color=#2AC3DE emoji=🔊
              super-o = {
                launch = [ "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@"
                  "5%+" ];
              };
            };
          }
      {
        name = "to normal";
        remap = {
          # rofi-entry skip reason=mode-switch
          super-space = {set_mode = "normal"; };
        };
        mode = "default";
      }
      {
        name = "to default";
        remap = {
          # rofi-entry skip reason=mode-switch
          super-space = {set_mode = "default"; };
        };
        mode = "normal";
      }
          {
            mode = "normal";
            remap = {
              # rofi-entry include category=Window color=#BB9AF7 emoji=⬅️
              shift-h = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "-100" "0"
                ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=⬇️
              shift-j = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "0" "100"
                ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=⬆️
              shift-k = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "0" "-100"
                ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=➡️
              shift-l = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "moveactive"
                  "100" "0"
                ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=↔️
              h = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "-100" "0"
                ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=↕️
              j = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "0" "100"
                ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=↕️
              k = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "0" "-100"
                ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=↔️
              l = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "resizeactive"
                  "100" "0"
                ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=🎯
              c = {
                launch = [
                  "${pkgs.hyprland}/bin/hyprctl"
                  "dispatch"
                  "centerwindow"
                ];
              };
              # rofi-entry include category=Brightness color=#E0AF68 emoji=🔆
              semicolon = {
                launch = [
                  "${pkgs.brightnessctl}/bin/brightnessctl"
                  "set"
                  "10%+"
                ];
              };
              # rofi-entry include category=Brightness color=#E0AF68 emoji=🌗
              comma = {
                launch = [
                  "${pkgs.lua}/bin/lua"
                  "-e"
                  /* lua */
                  ''
                    local handle = io.popen("${pkgs.brightnessctl}/bin/brightnessctl get")
                    local current = tonumber(handle:read("*a"))
                    handle:close()

                    local handle_max = io.popen("${pkgs.brightnessctl}/bin/brightnessctl max")
                    local max = tonumber(handle_max:read("*a"))
                    handle_max:close()

                    local current_percent = (current / max) * 100

                    if current_percent > 15 then
                      os.execute("${pkgs.brightnessctl}/bin/brightnessctl set 10%-")
                    elseif current_percent > 10 then
                      os.execute("${pkgs.brightnessctl}/bin/brightnessctl set 10%")
                    end
                  ''
                ];
              };
              # rofi-entry include category=Brightness color=#E0AF68 emoji=🔆
              "shift-semicolon" = {
                launch = [
                  "${pkgs.brightnessctl}/bin/brightnessctl"
                  "set"
                  "100%"
                ];
              };
              # rofi-entry include category=Brightness color=#E0AF68 emoji=🔅
              "shift-comma" = {
                launch = [
                  "${pkgs.brightnessctl}/bin/brightnessctl"
                  "set"
                  "10%"
                ];
              };
              # rofi-entry include category=Window color=#BB9AF7 emoji=💣
              "shift-x" = {
                remap = {
                  "shift-x" = {
                    launch = [
                      "${pkgs.hyprland}/bin/hyprctl"
                      "dispatch"
                      "forcekillactive"
                    ];
                  };
                };
              };
            };
          }
          {
            name = "firefox remaps";
            remap = {
              # rofi-entry skip reason=application-remap
              super-b = [ "c-l" "shift-5" "space" ];
              # rofi-entry skip reason=application-remap
              super-c = {
                remap = {
                  # rofi-entry skip reason=application-remap
                  super-c = "c-alt-z";
                  # rofi-entry skip reason=application-remap
                  super-u = "alt-1";
                  # rofi-entry skip reason=application-remap
                  super-i = "alt-2";
                  # rofi-entry skip reason=application-remap
                  super-o = "alt-3";
                  # rofi-entry skip reason=application-remap
                  super-p = "alt-4";
                  # rofi-entry skip reason=application-remap
                  super-leftbrace =  "alt-5";
                  # rofi-entry skip reason=application-remap
                  super-j = "alt-6";
                  # rofi-entry skip reason=application-remap
                  super-k = "alt-7";
                  # rofi-entry skip reason=application-remap
                  super-l = "alt-8";
                  # rofi-entry skip reason=application-remap
                  super-semicolon = "alt-9";
                };
              };
              # TODO: move to a move
              # super-c = {
              #   remap = {
              #     super-n = "alt-right";
              #     super-p = "alt-left";
              #     super-i = "alt-down";
              #     super-o = "alt-up";
              #   };
              # };
              # rofi-entry skip reason=application-remap
              super-z = "c-shift-tab";
              # rofi-entry skip reason=application-remap
              super-x = "c-tab";
            };
            application = {
              "only" = "firefox";
            };
          }
        ];
      };
    };

    home.packages = [ launcher.script clipboardDragonDrop ];

  };
}
