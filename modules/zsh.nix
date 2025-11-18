{ config, lib, pkgs, ... }:
let
  cfg = config.programs.sergio-zsh;
in {
  imports = [
    ./fzf.nix
  ];
  options = {
    programs.sergio-zsh.enable = lib.mkEnableOption "sergio's zsh configuration";
  };
  config = lib.mkIf cfg.enable {
    # Enable fzf module with zsh integration
    programs.sergio-fzf = {
      enable = true;
      zshIntegration = true;
    };
    
    programs.zsh = {
      enable = true;
      defaultKeymap = "viins";
      enableCompletion = true;
      history = {
        append = true;
      };
      syntaxHighlighting.enable = true;
      autosuggestion = {
        enable = true;
      };
      initContent = ''
        bindkey -v '^?' backward-delete-char
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        bindkey ^K fzf-cd-widget
        bindkey ^J fzf-file-widget
        bindkey ^O autosuggest-accept
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd ^F edit-command-line
        bindkey ^F edit-command-line
        # Temporary, gnome overrides the other var so we override back
        export EDITOR=nvim
        # Set secret env vars
        if [ -f ~/.secrets ]; then
          source ~/.secrets
        fi
        # Set window title to command and current directory
        preexec() {
          local cmd="''${1%% *}"
          printf "\e]0;%s - %s\a" "$cmd" "''${PWD/#$HOME/~}"
        }
      '';
    };
  };
}
