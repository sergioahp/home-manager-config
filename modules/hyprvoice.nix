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
          # gpt-transcribe takes the plural field; it replaces "language"
          # and setting both is rejected by the API.
          languages = [ "es" "en" ];
          model = "gpt-transcribe";
        };
        injection = {
          # Clipboard only: wtype types character by character into whatever
          # is focused, which has twice caused damage (a SUPER+Q keymap
          # collision that stopped the session, and a half-typed transcript
          # submitted into a prompt). The transcript lands on the clipboard
          # to paste manually instead.
          backends = [ "clipboard" ];
          # Unset timeouts decode as 0s and fail validation, which rejects every
          # subsequent config reload, so all three are set even when unused.
          ydotool_timeout = "5s";
          wtype_timeout = "5s";
          clipboard_timeout = "3s";
        };
        notifications = {
          type = "desktop";
        };
      };
    };
  };
}
