{ config, pkgs, lib, inputs, system }:

let
  categoryColors = config.categoryColors;
  rofiPowerMenu = "${inputs.rofi-power-menu}/rofi-power-menu";

  entries = [
    {
      key = "super-m super-l";
      desc = "Terminal (Kitty)";
      category = "Applications";
      color = categoryColors.Applications;
      glyph = "🖥️";
      args = [
        "${pkgs.uwsm}/bin/uwsm-app" "--"
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
      category = "Applications";
      color = categoryColors.Applications;
      glyph = "🦊";
      args = [
        "${pkgs.uwsm}/bin/uwsm-app" "--"
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
      category = "Utilities";
      color = categoryColors.Utilities;
      glyph = "🗂️";
      args = [
        "${pkgs.uwsm}/bin/uwsm-app" "--"
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
      category = "Monitoring";
      color = categoryColors.Monitoring;
      glyph = "📊";
      args = [
        "${pkgs.uwsm}/bin/uwsm-app" "--"
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
      category = "Applications";
      color = categoryColors.Applications;
      glyph = "🚀";
      args = [
        "${pkgs.rofi}/bin/rofi"
        "-show"
        "drun"
        "-run-command"
        "uwsm-app -- hyprctl dispatch exec -- {cmd}"
        "-theme-str"
        "window {width: 20%;}"
      ];
    }
    {
      key = "super-m super-k";
      desc = "Quick Start Menu";
      category = "Utilities";
      color = categoryColors.Utilities;
      glyph = "⚡";
      args = [
        "${inputs.rofi-switch-rust.packages.${system}.default}/bin/quick-start"
      ];
    }
    {
      key = "super-m super-i";
      desc = "Password Manager (Bitwarden)";
      category = "Applications";
      color = categoryColors.Applications;
      glyph = "🔐";
      args = [
        "${pkgs.uwsm}/bin/uwsm-app" "--"
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "--"
        "exec"
        "${pkgs.bitwarden-desktop}/bin/bitwarden"
      ];
    }
    {
      key = "super-m super-p";
      desc = "Power Menu";
      category = "Utilities";
      color = categoryColors.Utilities;
      # TODO: This is not aligned
      glyph = "⏻  ";
      args = [
        "${pkgs.rofi}/bin/rofi"
        "-show"
        "power-menu"
        "-modi"
        "power-menu:${rofiPowerMenu}"
      ];
    }
    {
      key = "super-. super-.";
      desc = "Voice Input Toggle";
      category = "Productivity";
      color = categoryColors.Productivity;
      glyph = "🎤";
      args = [
        "${inputs.hyprvoice.packages.${system}.default}/bin/hyprvoice"
        "toggle"
      ];
    }
    {
      key = "super-. super-c";
      desc = "Voice Input Cancel";
      category = "Productivity";
      color = categoryColors.Productivity;
      glyph = "❌";
      args = [
        "${inputs.hyprvoice.packages.${system}.default}/bin/hyprvoice"
        "cancel"
      ];
    }
    {
      key = "super-s super-e";
      desc = "Screenshot clipboard → Swappy";
      category = "Utilities";
      color = categoryColors.Utilities;
      glyph = "🖼️";
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
      category = "Utilities";
      color = categoryColors.Utilities;
      glyph = "📸";
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
      key = "super-s super-c";
      desc = "Color Picker";
      category = "Utilities";
      color = categoryColors.Utilities;
      glyph = "🎨";
      args = [
        "${pkgs.hyprpicker}/bin/hyprpicker"
        "-a"
      ];
    }
    {
      key = "super-u super-f";
      desc = "Dunst history pop";
      category = "Notifications";
      color = categoryColors.Notifications;
      glyph = "🕰️";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "history-pop"
      ];
    }
    {
      key = "super-u super-d";
      desc = "Dunst close notification";
      category = "Notifications";
      color = categoryColors.Notifications;
      glyph = "❌";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "close"
      ];
    }
    {
      key = "super-u super-s";
      desc = "Dunst close all";
      category = "Notifications";
      color = categoryColors.Notifications;
      glyph = "🧹";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "close-all"
      ];
    }
    {
      key = "super-u super-c";
      desc = "Dunst run action";
      category = "Notifications";
      color = categoryColors.Notifications;
      glyph = "🎯";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "action"
      ];
    }
    {
      key = "super-u super-e";
      desc = "Dunst open context";
      category = "Notifications";
      color = categoryColors.Notifications;
      glyph = "🛠️";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "context"
      ];
    }
    {
      key = "super-u super-t";
      desc = "Dunst toggle pause";
      category = "Notifications";
      color = categoryColors.Notifications;
      glyph = "⏯️";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "set-paused"
        "toggle"
      ];
    }
    {
      key = "super-u super-i";
      desc = "Dunst pause notifications";
      category = "Notifications";
      color = categoryColors.Notifications;
      glyph = "⏸️";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "set-paused"
        "true"
      ];
    }
    {
      key = "super-u super-o";
      desc = "Dunst resume notifications";
      category = "Notifications";
      color = categoryColors.Notifications;
      glyph = "▶️";
      args = [
        "${pkgs.dunst}/bin/dunstctl"
        "set-paused"
        "false"
      ];
    }
    {
      key = "super-d super-c";
      desc = "Kill active window";
      category = "Window";
      color = categoryColors.Window;
      glyph = "💀";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "killactive"
      ];
    }
    {
      key = "super-d super-j";
      desc = "Swap with next window";
      category = "Window";
      color = categoryColors.Window;
      glyph = "🔁";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "swapnext"
      ];
    }
    {
      key = "super-d super-k";
      desc = "Swap with previous window";
      category = "Window";
      color = categoryColors.Window;
      glyph = "↩️";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "🪟";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "togglefloating"
      ];
    }
    {
      key = "super-d super-f";
      desc = "Toggle fullscreen";
      category = "Window";
      color = categoryColors.Window;
      glyph = "🔳";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "fullscreen"
      ];
    }
    {
      key = "super-d super-comma";
      desc = "Set fullscreen state 1";
      category = "Window";
      color = categoryColors.Window;
      glyph = "🟥";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "📺";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "🔄";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "🪚";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "🚨";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "focusurgentorlast"
      ];
    }
    {
      key = "super-d super-s";
      desc = "Swap split panes";
      category = "Window";
      color = categoryColors.Window;
      glyph = "🧱";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "layoutmsg"
        "swapsplit"
      ];
    }
    {
      key = "shift-x shift-x";
      mode = "normal";
      desc = "Force kill active window";
      category = "Window";
      color = categoryColors.Window;
      glyph = "💣";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "forcekillactive"
      ];
    }
    {
      key = "super-comma";
      desc = "Focus next monitor";
      category = "Window";
      color = categoryColors.Window;
      glyph = "🪟";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "➡️";
      args = [
        "${pkgs.hyprland}/bin/hyprctl"
        "dispatch"
        "cyclenext"
      ];
    }
    {
      key = "super-k";
      desc = "Focus previous window";
      category = "Window";
      color = categoryColors.Window;
      glyph = "⬅️";
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
      category = "Media";
      color = categoryColors.Media;
      glyph = "⏯️";
      args = [
        "${pkgs.playerctl}/bin/playerctl"
        "play-pause"
      ];
    }
    {
      key = "super-y super-d";
      desc = "Media next track";
      category = "Media";
      color = categoryColors.Media;
      glyph = "⏭️";
      args = [
        "${pkgs.playerctl}/bin/playerctl"
        "next"
      ];
    }
    {
      key = "super-y super-f";
      desc = "Media previous track";
      category = "Media";
      color = categoryColors.Media;
      glyph = "⏮️";
      args = [
        "${pkgs.playerctl}/bin/playerctl"
        "previous"
      ];
    }
    {
      key = "super-y super-e";
      desc = "Toggle audio mute";
      category = "Audio";
      color = categoryColors.Audio;
      glyph = "🔇";
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
      category = "Audio";
      color = categoryColors.Audio;
      glyph = "🔉";
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
      category = "Audio";
      color = categoryColors.Audio;
      glyph = "🔊";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "⬅️";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "⬇️";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "⬆️";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "➡️";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "↔️";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "↕️";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "↕️";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "↔️";
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
      category = "Window";
      color = categoryColors.Window;
      glyph = "🎯";
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
      category = "Brightness";
      color = categoryColors.Brightness;
      glyph = "🔆";
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
      category = "Brightness";
      color = categoryColors.Brightness;
      glyph = "🌗";
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
      category = "Brightness";
      color = categoryColors.Brightness;
      glyph = "🔆";
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
      category = "Brightness";
      color = categoryColors.Brightness;
      glyph = "🔅";
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
      fields =
        [
          "key = ${luaString entry.key},"
          "desc = ${luaString entry.desc},"
          "category = ${luaString entry.category},"
          "color = ${luaString entry.color},"
          "glyph = ${luaString entry.glyph},"
          "args = ${luaArgs entry.args},"
        ]
        ++ (lib.optional (entry ? mode) "mode = ${luaString entry.mode},");
    in ''
      {
        ${lib.concatStringsSep "\n        " fields}
      }
    '';

  entriesLua = lib.concatStringsSep ",\n  " (map entryToLua entries);

  luaScript = ''
    #!${pkgs.lua5_4}/bin/lua

    local entries = {
      ${entriesLua}
    }

    local has_utf8, utf8 = pcall(require, "utf8")

    local function shell_escape(str)
      return "'" .. tostring(str):gsub("'", "'\"'\"'") .. "'"
    end

    local function escape_markup(str)
      return tostring(str)
        :gsub("&", "&amp;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
    end

    local function normalize_for_width(str)
      return tostring(str or "")
        :gsub("\239\184\143", "") -- U+FE0F VARIATION SELECTOR-16
        :gsub("\226\128\141", "") -- U+200D ZERO WIDTH JOINER
    end

    local function str_width(str)
      str = tostring(str or "")
      local width_str = normalize_for_width(str)
      if has_utf8 and utf8.len then
        local ok, len = pcall(utf8.len, width_str)
        if ok and len then
          return len
        end
      end
      local _, count = width_str:gsub("[^\128-\191]", "")
      return count
    end

    local function pad_right(str, width)
      str = tostring(str or "")
      local len = str_width(str)
      if len >= width then
        return str
      end
      return str .. string.rep(" ", width - len)
    end

    local function compute_widths(data)
      local widths = { glyph = 0, desc = 0, key = 0, category = 0 }
      for _, entry in ipairs(data) do
        local glyph = entry.glyph or ""
        local desc = entry.desc or ""
        local key = entry.key or ""
        local mode = entry.mode
        if mode and mode ~= "" and mode ~= "default" then
          key = string.format("%s (%s)", key, mode)
        end
        local category = entry.category or ""
        widths.glyph = math.max(widths.glyph, str_width(glyph))
        widths.desc = math.max(widths.desc, str_width(desc))
        widths.key = math.max(widths.key, str_width(key))
        widths.category = math.max(widths.category, str_width(category))
      end
      return widths
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

    local widths = compute_widths(entries)

    local function format_column(str, width)
      local padded = pad_right(str, width)
      local escaped = escape_markup(padded)
      return escaped:gsub(" ", "&#160;")
    end

    local function format_label(entry)
      local color = entry.color or "#c0caf5"
      local glyph = entry.glyph or ""
      local key = entry.key or ""
      local desc = entry.desc or ""
      local category = entry.category or ""
      local mode = entry.mode
      if mode and mode ~= "" and mode ~= "default" then
        key = string.format("%s (%s)", key, mode)
      end
      glyph = format_column(glyph, widths.glyph)
      desc = format_column(desc, widths.desc)
      key = format_column(key, widths.key)
      category = format_column(category, widths.category)
      return string.format(
        "%s&#160;&#160;<span color='%s'>%s&#160;&#160;<span weight='bold'>%s</span>&#160;&#160;<span size='small'>[%s]</span></span>",
        glyph,
        color,
        desc,
        key,
        category
      )
    end

    local tmp_path = os.tmpname()
    local file = assert(io.open(tmp_path, "w"))
    local total_entries = #entries
    for i, entry in ipairs(entries) do
      local label = format_label(entry)
      file:write(label)
      if i < total_entries then
        file:write("\n")
      end
    end
    file:close()

    local rofi_bin = ${luaString "${pkgs.rofi}/bin/rofi"}
    local prompt = "xremap"
    local unpack = table.unpack or unpack

    local rofi_cmd = string.format(
      "%s -dmenu -i -markup-rows -format i -p %s -input %s",
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
