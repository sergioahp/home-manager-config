{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sergio-hypridle;
in {
  options = {
    programs.sergio-hypridle.enable = lib.mkEnableOption "sergio's hypridle config";
  };

  config = lib.mkIf cfg.enable (
    let
      hyprlockBin    = lib.getExe pkgs.hyprlock;
      systemdInhibit = lib.getExe' pkgs.systemd "systemd-inhibit";
      pkill          = lib.getExe' pkgs.procps "pkill";
      inhibitTag     = "hypridle-lock-inhibit";

      lockInhibitOn = pkgs.writeShellScript "lock-inhibit-on" ''
        set -eu
        ${pkill} -f "${inhibitTag}" || true
        ${systemdInhibit} --what=handle-lid-switch:sleep --mode=block \
          --who=${inhibitTag} --why="Screen locked" \
          sleep infinity &
        disown
      '';

      lockInhibitOff = pkgs.writeShellScript "lock-inhibit-off" ''
        ${pkill} -f "${inhibitTag}" || true
      '';
    in {
      services.hypridle = {
        enable = true;

        settings = {
          general = {
            lock_cmd         = "${hyprlockBin} --grace 10";
            on_lock_cmd      = "${lockInhibitOn}";
            on_unlock_cmd    = "${lockInhibitOff}";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd  = "hyprctl dispatch dpms on";
          };

          listener = [
            {
              timeout = 600; # 10 minutes
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 630; # 10.5 minutes
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };
    }
  );
}
