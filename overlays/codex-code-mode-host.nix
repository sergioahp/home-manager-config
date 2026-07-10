# TEMPORARY shim, remove once numtide/llm-agents.nix#6631 lands:
# their codex package misses the codex-code-mode-host helper that
# codex >= 0.144.0 spawns for every shell command, breaking all
# command execution. Upstream ships it prebuilt (static musl), so
# fetch it (codex-code-mode-host-bin flake input, pinned by flake.lock)
# and point codex at it via CODEX_CODE_MODE_HOST_PATH instead of
# recompiling the whole rust workspace. The input URL pins the host
# version; the assert below fails loudly when llm-agents bumps codex -
# check if the shim is still needed before bumping the input URL.
inputs: final: prev: {
  codex =
    let
      base = final.llm-agents.codex;
      hostVersion = "0.144.0";
      hostBin = final.runCommand "codex-code-mode-host-${hostVersion}" { } ''
        mkdir -p $out/bin
        install -m755 ${inputs.codex-code-mode-host-bin}/codex-code-mode-host-* \
          $out/bin/codex-code-mode-host
      '';
    in
    assert final.lib.assertMsg (base.version == hostVersion)
      ("codex-code-mode-host-bin input is pinned to ${hostVersion} but "
        + "llm-agents' codex is ${base.version}; if numtide/llm-agents.nix#6631 "
        + "landed drop this shim, otherwise bump the input URL in flake.nix");
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
}
