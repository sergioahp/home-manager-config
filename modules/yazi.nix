{ config, lib, pkgs, ... }:
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
      settings = {
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
              run   = ''${pkgs.zathura}/bin/zathura "$@"'';
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
            { name = "*.djvu";         use = "docs";   }
            { name = "*.pdf";          use = "docs";   }
            { name = "*.epub";         use = "docs";   }
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
            run = ''shell -- ${pkgs.xdragon}/bin/xdragon "$@"'';
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
