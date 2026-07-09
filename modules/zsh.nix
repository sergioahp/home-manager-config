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

    home.sessionVariables = {
      # Avoid waiting for key timeout when using vi mode
      KEYTIMEOUT = 1;
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
      initContent =
        let
          personal-api-keys = "${config.home.homeDirectory}/.config/sops-nix/secrets/personal-api-keys";
        in
        /* bash */ ''
        bindkey -v '^?' backward-delete-char

        # Cursor shape per vi mode: block in normal, bar in insert
        function zle-keymap-select {
          case $KEYMAP in
            vicmd) printf '\e[2 q';;
            viins|main) printf '\e[6 q';;
          esac
        }
        zle -N zle-keymap-select
        function zle-line-init {
          printf '\e[6 q'
        }
        zle -N zle-line-init

        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        bindkey ^K fzf-cd-widget
        bindkey ^J fzf-file-widget
        bindkey ^O autosuggest-accept

        # Accept the autosuggestion one word at a time with Ctrl+, mirroring
        # minuet.nvim's <C-,> (accept_word). Ctrl+, reaches zsh as \e[44;5u via
        # the kitty-extended-keys map (send_text application). zsh-autosuggestions
        # does the partial accept for any widget in
        # ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS; the widget only has to push
        # CURSOR into the suggestion. .vi-forward-word-end is zsh's "e" motion and
        # lands on the word's last char, so step one past it to take the whole
        # word (the dot calls the builtin, bypassing the autosuggest wrapper).
        function autosuggest-accept-word() {
          zle .vi-forward-word-end
          (( CURSOR < $#BUFFER )) && (( CURSOR++ ))
        }
        zle -N autosuggest-accept-word
        ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(autosuggest-accept-word)
        bindkey '^[[44;5u' autosuggest-accept-word

        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd ^F edit-command-line
        bindkey ^F edit-command-line
        # Temporary, gnome overrides the other var so we override back
        export EDITOR=nvim
        # Set up API keys only when the secrets directory exists and is readable.
        if [ -d "${personal-api-keys}" ] && [ -r "${personal-api-keys}" ]; then
          # If the directory is empty, the glob "*" may stay literal; guard with -e.
          for key in "${personal-api-keys}"/*; do
            [ -e "$key" ] || break
            [ -r "$key" ] || continue

            # Not `name`: nix dev shells export `name` and Starship prints it.
            key_name="$(basename "$key")"

            case "$key_name" in
              [A-Za-z]*([A-Za-z0-9_]))
                export "$key_name=$(cat "$key")"
                ;;
            esac
          done
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
