# Chromium only auto-detects a keyring backend on GNOME/KDE; under
# XDG_CURRENT_DESKTOP=Hyprland it silently falls back to plaintext
# and claude-desktop warns that sign-in won't be saved. Force the
# Secret Service backend (gnome-keyring, enabled system-side).
final: prev: {
  claude-desktop =
    let
      base = final.llm-agents.claude-desktop;
    in
    final.runCommand "claude-desktop-with-keyring-flag-${base.version}"
      { nativeBuildInputs = [ final.makeWrapper ]; }
      ''
        mkdir -p $out/bin
        for f in ${base}/*; do
          [ "$(basename "$f")" = bin ] || ln -s "$f" $out/
        done
        makeWrapper ${base}/bin/claude-desktop $out/bin/claude-desktop \
          --add-flags --password-store=gnome-libsecret
      '';
}
