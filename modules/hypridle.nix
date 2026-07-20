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
      systemdRun     = lib.getExe' pkgs.systemd "systemd-run";
      systemctl      = lib.getExe' pkgs.systemd "systemctl";
      inhibitTag     = "hypridle-lock-inhibit";

      # Run the inhibitor as its own transient user unit, not as a disowned
      # child of hypridle.service. hypridle has KillMode=control-group, so a
      # `home-manager switch` that restarts the service would drop a child
      # inhibitor along with it -- silently un-blocking handle-lid-switch:sleep
      # and letting logind suspend a lid-closed, remotely-used box. As its own
      # unit the inhibitor survives hypridle restarts. --collect GCs the unit if
      # it ever exits, so the next lock can reuse the name.
      lockInhibitOn = pkgs.writeShellScript "lock-inhibit-on" ''
        set -eu
        ${systemctl} --user stop ${inhibitTag}.service 2>/dev/null || true
        ${systemdRun} --user --unit=${inhibitTag} --collect \
          ${systemdInhibit} --what=handle-lid-switch:sleep --mode=block \
            --who=${inhibitTag} --why="Screen locked" \
            sleep infinity
      '';

      lockInhibitOff = pkgs.writeShellScript "lock-inhibit-off" ''
        ${systemctl} --user stop ${inhibitTag}.service 2>/dev/null || true
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
