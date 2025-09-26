{ config, lib, pkgs, ... }:
let
  cfg = config.programs.sergio-fzf;
in {
  imports = [];
  options = {
    programs.sergio-fzf = {
      enable = lib.mkEnableOption "sergio's fzf configuration";
      zshIntegration = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable zsh integration for fzf";
      };
      bashIntegration = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable bash integration for fzf";
      };
      fishIntegration = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable fish integration for fzf";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    # Placeholder - fzf configuration will go here
    programs.fzf = {
      enable = true;
      enableZshIntegration = cfg.zshIntegration;
      enableBashIntegration = cfg.bashIntegration;
      enableFishIntegration = cfg.fishIntegration;
      defaultOptions = [
        "--layout=reverse"
        "--info=inline"
        "--height=40%"
        "--bind='ctrl-/:toggle-preview'"
        "--multi"
      ];
      historyWidgetOptions = [
        "--with-nth 2.."
        "--bind='ctrl-y:execute-silent(echo -n {2..} | ${pkgs.wl-clipboard}/bin/wl-copy)+abort'"
      ];
      fileWidgetOptions = [
        "--walker-skip=.git,node_modules,target"
        "--preview='${pkgs.bat}/bin/bat --style=plain --color=always --line-range :500 {}'"
        "--bind='ctrl-/:change-preview-window(down|hidden|)'"
      ];
      changeDirWidgetOptions = [
        "--preview='${pkgs.eza}/bin/eza -T --color=always {} | head -200'"
      ];
    };
  };
}
