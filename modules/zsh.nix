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

        # Conditional aliases: use plain commands in Claude Code, fancy versions otherwise
        if [ -z "$CLAUDECODE" ]; then
          # Normal interactive shell - use fancy/safe versions
          alias ls='${pkgs.eza}/bin/eza'
          alias tree='${pkgs.eza}/bin/eza -T'
          alias cat='${pkgs.bat}/bin/bat --paging=never --style=plain'
          alias cp='cp -i'
          alias mv='mv -i'
          alias rm='rm -I'
        else
          # Claude Code environment - use original commands without interactive prompts
          alias ls='ls'
          alias tree='tree'
          alias cat='cat'
          alias cp='cp'
          alias mv='mv'
          alias rm='rm'
        fi
      '';
    };
  };
}
