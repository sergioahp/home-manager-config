{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sergio-hyprvoice;
in
{
  options = {
    programs.sergio-hyprvoice.enable = lib.mkEnableOption "sergio's hyprvoice configuration";
  };

  config = lib.mkIf cfg.enable {
    services.hyprvoice = {
      enable = true;
      environmentFile = "${config.home.homeDirectory}/.config/hyprvoice/env";
      settings = {
        recording = {
          sample_rate = 16000;
          channels = 1;
          format = "s16";
          buffer_size = 8192;
          device = "";
          channel_buffer_size = 30;
          timeout = "5m";
        };
        transcription = {
          provider = "openai";
          language = "";
          model = "whisper-1";
        };
        injection = {
          mode = "fallback";
          restore_clipboard = true;
          wtype_timeout = "5s";
          clipboard_timeout = "3s";
        };
        notifications = {
          enabled = true;
          type = "desktop";
        };
      };
    };
  };
}
