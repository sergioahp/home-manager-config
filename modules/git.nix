{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sergio-git;
in
{
  options = {
    programs.sergio-git.enable = lib.mkEnableOption "sergio's git configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.gh = {
      enable = true;
    };

    programs.git = {
      enable = true;
      settings = {
        user.name = "sergioahp";
        user.email = "sergioahp@proton.me";
        user.signingkey = "4E3F5ADE5C10EDB6";
        init.defaultBranch = "master";
        commit.gpgsign = true;
        tag.gpgSign = true;
        merge.tool = "vimdiff";
        mergetool.vimdiff.cmd = "${pkgs.neovim}/bin/nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
        diff.tool = "vimdiff";
        difftool.vimdiff.cmd = "${pkgs.neovim}/bin/nvim -d $LOCAL $REMOTE";
        alias = {
          a   = "add";
          s   = "status";
          f   = "fetch";
          u   = "pull";
          l   = "log         -n 15   --oneline --decorate";
          lg  = "log         --graph --oneline --decorate";
          lga = "log --all   --graph --oneline --decorate";
          co  = "checkout";
          c   = "commit -v";
          ca  = "commit -v --amend";
          b   = "branch";
          d   = "diff                      -M -C -C --color-moved --color-moved-ws=allow-indentation-change";
          dw  = "diff          --word-diff -M -C -C --color-moved --color-moved-ws=allow-indentation-change";
          ds  = "diff --staged             -M -C -C --color-moved --color-moved-ws=allow-indentation-change";
          dsw = "diff --staged --word-diff -M -C -C --color-moved --color-moved-ws=allow-indentation-change";
          st  = "stash";
        };
      };
    };
  };
}
