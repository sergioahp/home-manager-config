{ config, lib, pkgs, ... }:
let
  cfg = config.programs.sergio-kitty;
in {
  imports = [];
  options = {
    programs.sergio-kitty.enable = lib.mkEnableOption "sergio's kitty terminal config";
  };
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        # You can add your kitty configuration here
        # For example:
        # font_family = "DejaVu Sans Mono";
        # font_size = 12;
        # enable_audio_bell = false;
      };
    };
  };
}