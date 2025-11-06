{ pkgs, lib, inputs, system }:

let
  entries = [
    {
      key = "super-m super-l";
      desc = "Terminal (Kitty)";
      args = [
        "${pkgs.uwsm}/bin/uwsm"
        "app"
        "--"
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "--"
        "exec"
        "${pkgs.kitty}/bin/kitty"
      ];
    }
    {
      key = "super-m super-f";
      desc = "Firefox Browser";
      args = [
        "${pkgs.uwsm}/bin/uwsm"
        "app"
        "--"
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "--"
        "exec"
        "${pkgs.firefox}/bin/firefox"
      ];
    }
    {
      key = "super-m super-e";
      desc = "File Manager (Ranger)";
      args = [
        "${pkgs.uwsm}/bin/uwsm"
        "app"
        "--"
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "--"
        "exec"
        "${pkgs.kitty}/bin/kitty"
        "${pkgs.ranger}/bin/ranger"
      ];
    }
    {
      key = "super-m super-o";
      desc = "System Monitor (btop)";
      args = [
        "${pkgs.uwsm}/bin/uwsm"
        "app"
        "--"
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "--"
        "exec"
        "${pkgs.kitty}/bin/kitty"
        "${pkgs.btop}/bin/btop"
      ];
    }
    {
      key = "super-m super-m";
      desc = "Application Launcher (Rofi)";
      args = [
        "${pkgs.rofi}/bin/rofi"
        "-show"
        "drun"
        "-theme-str"
        "window {width: 20%;}"
      ];
    }
    {
      key = "super-m super-k";
      desc = "Quick Start Menu";
      args = [
        "${inputs.rofi-switch-rust.packages.${system}.default}/bin/quick-start"
      ];
    }
    {
      key = "super-m super-i";
      desc = "Password Manager (Bitwarden)";
      args = [
        "${pkgs.uwsm}/bin/uwsm"
        "app"
        "--"
        "${pkgs.bitwarden-desktop}/bin/bitwarden"
      ];
    }
    {
      key = "super-s super-e";
      desc = "Screenshot clipboard → Swappy";
      args = [
        "${pkgs.bash}/bin/sh"
        "-c"
        ''
          ${pkgs.wl-clipboard}/bin/wl-paste --type image/png |
          ${pkgs.swappy}/bin/swappy -f -
        ''
      ];
    }
    {
      key = "super-s super-d";
      desc = "Screenshot region → Swappy";
      args = [
        "${pkgs.bash}/bin/sh"
        "-c"
        ''
          ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -w 0)" - |
          ${pkgs.swappy}/bin/swappy -f -
        ''
      ];
    }
    {
      key = "super-u super-f";
      desc = "Dunst history pop";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "history-pop"
      ];
    }
    {
      key = "super-u super-d";
      desc = "Dunst close notification";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "close"
      ];
    }
    {
      key = "super-u super-s";
      desc = "Dunst close all";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "close-all"
      ];
    }
    {
      key = "super-u super-c";
      desc = "Dunst run action";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "action"
      ];
    }
    {
      key = "super-u super-e";
      desc = "Dunst open context";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "context"
      ];
    }
    {
      key = "super-u super-t";
      desc = "Dunst toggle pause";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "set-paused"
        "toggle"
      ];
    }
    {
      key = "super-u super-i";
      desc = "Dunst pause notifications";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "set-paused"
        "true"
      ];
    }
    {
      key = "super-u super-o";
      desc = "Dunst resume notifications";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "set-paused"
        "false"
      ];
    }
    {
      key = "super-d super-c";
      desc = "Kill active window";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "killactive"
      ];
    }
    {
      key = "super-d super-j";
      desc = "Swap with next window";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "swapnext"
      ];
    }
    {
      key = "super-d super-k";
      desc = "Swap with previous window";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "swapnext"
        "prev"
      ];
    }
    {
      key = "super-d super-u";
      desc = "Toggle floating";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "togglefloating"
      ];
    }
    {
      key = "super-d super-f";
      desc = "Toggle fullscreen";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "fullscreen"
      ];
    }
    {
      key = "super-d super-comma";
      desc = "Set fullscreen state 1";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "fullscreenstate"
        "1"
      ];
    }
    {
      key = "super-d super-m";
      desc = "Move window to next monitor";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "movewindow"
        "mon:+1"
      ];
    }
    {
      key = "super-d super-p";
      desc = "Swap active workspaces";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "swapactiveworkspaces"
        "0"
        "1"
      ];
    }
    {
      key = "super-d super-t";
      desc = "Toggle split layout";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "layoutmsg"
        "togglesplit"
      ];
    }
    {
      key = "super-d super-g";
      desc = "Focus urgent/last window";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "focusurgentorlast"
      ];
    }
    {
      key = "super-d super-s";
      desc = "Swap split panes";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "layoutmsg"
        "swapsplit"
      ];
    }
    {
      key = "super-comma";
      desc = "Focus next monitor";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "focusmonitor"
        "+1"
      ];
    }
    {
      key = "super-j";
      desc = "Focus next window";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "cyclenext"
      ];
    }
    {
      key = "super-k";
      desc = "Focus previous window";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "cyclenext"
        "prev"
      ];
    }
    {
      key = "super-y super-s";
      desc = "Media play/pause";
      args = [
        "${pkgs.playerctl}/bin/playerctl"
        "play-pause"
      ];
    }
    {
      key = "super-y super-d";
      desc = "Media next track";
      args = [
        "${pkgs.playerctl}/bin/playerctl"
        "next"
      ];
    }
    {
      key = "super-y super-f";
      desc = "Media previous track";
      args = [
        "${pkgs.playerctl}/bin/playerctl"
        "previous"
      ];
    }
    {
      key = "super-y super-e";
      desc = "Toggle audio mute";
      args = [
        "${pkgs.wireplumber}/bin/wpctl"
        "set-mute"
        "@DEFAULT_AUDIO_SINK@"
        "toggle"
      ];
    }
    {
      key = "super-i";
      desc = "Volume down 5%";
      args = [
        "${pkgs.wireplumber}/bin/wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "5%-"
      ];
    }
    {
      key = "super-o";
      desc = "Volume up 5%";
      args = [
        "${pkgs.wireplumber}/bin/wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "5%+"
      ];
    }
    {
      key = "shift-h";
      mode = "normal";
      desc = "Move active window left";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "moveactive"
        "-100"
        "0"
      ];
    }
    {
      key = "shift-j";
      mode = "normal";
      desc = "Move active window down";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "moveactive"
        "0"
        "100"
      ];
    }
    {
      key = "shift-k";
      mode = "normal";
      desc = "Move active window up";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "moveactive"
        "0"
        "-100"
      ];
    }
    {
      key = "shift-l";
      mode = "normal";
      desc = "Move active window right";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "moveactive"
        "100"
        "0"
      ];
    }
    {
      key = "h";
      mode = "normal";
      desc = "Resize active window wider (left)";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "resizeactive"
        "-100"
        "0"
      ];
    }
    {
      key = "j";
      mode = "normal";
      desc = "Resize active window taller";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "resizeactive"
        "0"
        "100"
      ];
    }
    {
      key = "k";
      mode = "normal";
      desc = "Resize active window shorter";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "resizeactive"
        "0"
        "-100"
      ];
    }
    {
      key = "l";
      mode = "normal";
      desc = "Resize active window narrower (right)";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "resizeactive"
        "100"
        "0"
      ];
    }
    {
      key = "c";
      mode = "normal";
      desc = "Center active window";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "centerwindow"
      ];
    }
    {
      key = "semicolon";
      mode = "normal";
      desc = "Increase brightness 10%";
      args = [
        "${pkgs.brightnessctl}/bin/brightnessctl"
        "set"
        "10%+"
      ];
    }
    {
      key = "comma";
      mode = "normal";
      desc = "Adaptive brightness down";
      args = [
        "${pkgs.lua}/bin/lua"
        "-e"
        ''
          local handle = io.popen("${pkgs.brightnessctl}/bin/brightnessctl get")
          local current = tonumber(handle:read("*a"))
          handle:close()

          local handle_max = io.popen("${pkgs.brightnessctl}/bin/brightnessctl max")
          local max = tonumber(handle_max:read("*a"))
          handle_max:close()

          local current_percent = (current / max) * 100

          if current_percent > 15 then
            os.execute("${pkgs.brightnessctl}/bin/brightnessctl set 10%-")
          elseif current_percent > 10 then
            os.execute("${pkgs.brightnessctl}/bin/brightnessctl set 10%")
          end
        ''
      ];
    }
    {
      key = "shift-semicolon";
      mode = "normal";
      desc = "Set brightness 100%";
      args = [
        "${pkgs.brightnessctl}/bin/brightnessctl"
        "set"
        "100%"
      ];
    }
    {
      key = "shift-comma";
      mode = "normal";
      desc = "Set brightness 10%";
      args = [
        "${pkgs.brightnessctl}/bin/brightnessctl"
        "set"
        "10%"
      ];
    }
  ];

  luaString = str: builtins.toJSON str;

  luaArgs = args: "{ " + lib.concatStringsSep ", " (map luaString args) + " }";

  entryToLua = entry:
    let
      modeLine =
        if entry ? mode then
          "\n        mode = ${luaString entry.mode},"
        else
          "";
    in ''
      {
        key = ${luaString entry.key},
        desc = ${luaString entry.desc},
        args = ${luaArgs entry.args},${modeLine}
      }
    '';

  entriesLua = lib.concatStringsSep ",\n  " (map entryToLua entries);

  luaScript = ''
    #!${pkgs.lua}/bin/lua

    local entries = {
      ${entriesLua}
    }

    local function shell_escape(str)
      return "'" .. tostring(str):gsub("'", "'\"'\"'") .. "'"
    end

    local function run(cmd, ...)
      local args = { cmd, ... }
      if #args == 0 then
        return false
      end
      local parts = {}
      for i, arg in ipairs(args) do
        parts[i] = shell_escape(arg)
      end
      local command = table.concat(parts, " ")
      local ok, how, code = os.execute(command)
      if ok == true or ok == 0 then
        return true
      end
      if how == "exit" then
        return code == 0
      end
      return false
    end

    local function format_label(entry)
      local key = entry.key or ""
      if entry.mode and entry.mode ~= "" and entry.mode ~= "default" then
        key = string.format("[%s] %s", entry.mode, key)
      end
      return string.format("%-28s  %s", key, entry.desc or "")
    end

    local labels = {}
    for i, entry in ipairs(entries) do
      labels[i] = format_label(entry)
    end

    local tmp_path = os.tmpname()
    local file = assert(io.open(tmp_path, "w"))
    file:write(table.concat(labels, "\n"))
    file:close()

    local rofi_bin = ${luaString "${pkgs.rofi}/bin/rofi"}
    local prompt = "xremap"
    local unpack = table.unpack or unpack

    local rofi_cmd = string.format(
      "%s -dmenu -i -format i -p %s -input %s",
      shell_escape(rofi_bin),
      shell_escape(prompt),
      shell_escape(tmp_path)
    )

    local handle = io.popen(rofi_cmd, "r")
    if not handle then
      os.remove(tmp_path)
      os.exit(1)
    end

    local selected = handle:read("*l")
    handle:close()
    os.remove(tmp_path)

    if not selected or selected == "" then
      os.exit(0)
    end

    local index = tonumber(selected)
    if not index then
      os.exit(1)
    end

    local entry = entries[index + 1]
    if not entry then
      os.exit(1)
    end

    local ok = run(unpack(entry.args))
    if ok then
      os.exit(0)
    else
      os.exit(1)
    end
  '';
in {
  entries = entries;
  script = pkgs.writeScriptBin "xremap-launcher" luaScript;
}
