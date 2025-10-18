{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sergio-hypridle;
in {
  options = {
    programs.sergio-hypridle.enable = lib.mkEnableOption "sergio's hypridle config";
  };

  config = lib.mkIf cfg.enable (
    let
      hyprlockBin = lib.getExe pkgs.hyprlock;
      systemdInhibit = lib.getExe' pkgs.systemd "systemd-inhibit";
      pgrep = lib.getExe' pkgs.procps "pgrep";
      hyprlockInhibitor = pkgs.writeShellScriptBin "hyprlock-inhibit" ''
        set -euo pipefail

        if ${pgrep} -x hyprlock >/dev/null; then
          exit 0
        fi

        exec ${systemdInhibit} --what=handle-lid-switch:sleep --mode=block \
          --who=hyprlock --why="Screen locked" \
          ${hyprlockBin} "$@"
      '';
    in {
      services.hypridle = {
        enable = true;

        settings = {
          general = {
            lock_cmd = "${hyprlockInhibitor}/bin/hyprlock-inhibit";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };

          listener = [
            {
              timeout = 300; # 5 minutes
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330; # 5.5 minutes
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 1800; # 30 minutes
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
    }
  );
}
