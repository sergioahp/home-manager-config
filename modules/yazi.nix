{ config, lib, pkgs, pkgs-bitwarden-zathura, ... }:
let
  cfg = config.programs.sergio-yazi;
in {
  options = {
    programs.sergio-yazi.enable = lib.mkEnableOption "sergio's yazi config";
  };
  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
      settings = {
        plugin = {
          prepend_preloaders = [
            { mime = "video/*"; run = "noop"; }
          ];
        };
        opener = {
          images = [
            {
              run   = ''${pkgs.nsxiv}/bin/nsxiv "$@"'';
              orphan = true;
              desc  = "nsxiv (image viewer)";
            }
          ];
          docs = [
            {
              run   = ''${pkgs-bitwarden-zathura.zathura}/bin/zathura "$@"'';
              orphan = true;
              desc  = "zathura (document viewer)";
            }
          ];
          video = [
            {
              run   = ''${pkgs.mpv}/bin/mpv --fs "$@"'';
              orphan = true;
              desc  = "mpv (video player)";
            }
          ];
          edit = [
            {
              run   = ''${pkgs.neovim}/bin/nvim "$@"'';
              block = true;
              desc  = "Neovim (text editor)";
            }
          ];
        };
        open = {
          prepend_rules = [
            { mime = "image/vnd.djvu"; use = "docs";   }
            { mime = "image/x-djvu";   use = "docs";   }
            { url = "*.djvu";          use = "docs";   }
            { url = "*.djv";           use = "docs";   }
            { url = "*.pdf";           use = "docs";   }
            { url = "*.epub";          use = "docs";   }
            { mime = "video/*";        use = "video";  }
            { mime = "text/*";         use = "edit";   }
            { mime = "image/*";        use = "images"; }
          ];
        };
      };
      keymap = {
        mgr.prepend_keymap = [
          {
            on = "<C-d>";
            run = ''shell -- ${pkgs.dragon-drop}/bin/dragon-drop "$@"'';
            desc = "Dragon drop";
          }
          {
            on = "<C-o>";
            run = "back";
            desc = "Dir history back";
          }
          {
            on = "<C-i>";
            run = "forward";
            desc = "Dir history forward";
          }
        ];
      };
    };
  };
}
