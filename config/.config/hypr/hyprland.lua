-- Hyprland Configuration

-- PROGRAMS {{{

local terminal = "kitty"
local fileManager = "dolphin"
local browser = "firefox" -- librewolf
local menu = "rofi -show drun"

-- }}}

-- MONITORS {{{

-- Check for available monitors with `hyprctl monitors all` (without `all` to only list active outputs). Can and should
-- keep monitors from other systems if they do not overlap.

-- On pavilion, use single monitor Lenovo G27q-20.
-- hl.monitor({ output = "DP-1", mode = "2560x1440@164.85", position = "0x0", scale = 1 })

-- On aspire, use internal screen and add external screen above when connected.
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60.02", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-up", scale = 1 })

-- On aspire, use internal screen and add 4K external screen as 2K monitor.
hl.monitor({ output = "eDP-1", mode = "1920x1080@60.02", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@59.95", position = "-320x-1440", scale = 1 })

-- On aspire, use internal screen and add 4K external screen in native resolution & scaled.
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60.02", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60.00", position = "-960x-2160", scale = 1.5 })

-- On aspire at home, use internal screen and add Lenovo G27q-20 above when connected.
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60.02", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144.00", position = "-320x-1440", scale = 1 })

-- On aspire, use internal screen and mirror onto external screen when connected.
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60.02", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "0x0", scale = 1, mirror = "eDP-1" })

-- On aspire, mirror internal screen onto Samsung 4K TV at 1080p (preferred 4K only runs at 30Hz over its HDMI).
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60.02", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60.00", position = "0x0", scale = 1, mirror = "eDP-1" })

-- On aspire, mirror Samsung 4K TV onto internal screen at 1080p (preferred 4K only runs at 30Hz over its HDMI).
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60.02", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@30.00Hz", position = "-960x-2160", scale = 2 })

-- On aspire, mirror external screen onto internal screen when connected.
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, mirror = "HDMI-A-1" })
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "0x0", scale = 1 })

-- On aspire, mirror G27q-20 external screen onto internal screen when connected.
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, mirror = "HDMI-A-1" })
-- hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144.00", position = "0x0", scale = 1 })

-- On aspire, mirror external screen onto internal screen when connected.
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, mirror = "HDMI-A-1" })
-- hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@60.00", position = "0x0", scale = 1 })

-- }}}

-- AUTOSTART {{{

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper") -- Show wallpaper
    hl.exec_cmd("~/.config/waybar/reload.sh") -- Show waybar and reload on config change
    hl.exec_cmd("nm-applet") -- Show network manager applet in waybar
    hl.exec_cmd("wl-paste --watch cliphist store") -- Copying with wl-paste adds to cliphist
    hl.exec_cmd("dunst") -- Show notifications
    hl.exec_cmd("syncthingtray-qt6 --wait") -- Show Syncthing tray icon
    hl.exec_cmd("ntfyDesktop") -- Show ntfy tray icon
    hl.exec_cmd("/usr/bin/nextcloud --background") -- Show Nextcloud tray icon
    hl.exec_cmd("keepassxc") -- Show KeePassXC tray icon
    hl.exec_cmd("protonmail-bridge --no-window") -- Show Proton Mail Bridge tray icon

    -- Start xdg-desktop-portal (required for chromium --app, file picker, etc.)
    hl.exec_cmd("/usr/lib/xdg-desktop-portal")

    -- Open browser on workspace 1.
    hl.exec_cmd(browser, { workspace = "1 silent" })

    -- Open Thunderbird on workspace 8 and Obsidian devault on workspace 9.
    hl.exec_cmd("sleep 30 && thunderbird", { workspace = "8 silent" })
    hl.exec_cmd([[obsidian "obsidian://open?vault=devault"]], { workspace = "9 silent" })
    -- hl.exec_cmd(terminal .. " -e rmpc", { workspace = "10 silent" })
    -- hl.exec_cmd("spotify-launcher", { workspace = "10 silent" }) -- FIX: show on workspace 10 instead of 1
end)

-- No popup on update or donation request.
hl.config({
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})

-- }}}

-- ENVIRONMENT VARIABLES {{{

-- Size of cursor.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland:GNOME")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("ANKI_WAYLAND", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- }}}

-- LOOK {{{

hl.config({
    general = {
        -- No gaps between windows and screen edges.
        gaps_in = 0,
        gaps_out = 0,

        -- Border size and blue-green-ish color around focused window.
        border_size = 3,
        col = {
            active_border = { colors = { "rgb(33ccff)", "rgb(00ff99)" }, angle = 30 },
            inactive_border = "rgb(000000)",
        },

        -- Holding border with mouse does not accidentally resize windows.
        resize_on_border = false,

        -- Tearing is enabled and may be disabled if tearing actually occurs.
        allow_tearing = true,

        -- Layout of windows is dwindle instead of master for improved flexibility.
        layout = "dwindle",
    },

    decoration = {
        -- Disable rounded corners.
        rounding = 0,

        -- Both focused and unfocused windows are fully opaque for maximum readability.
        active_opacity = 1,
        inactive_opacity = 1,

        -- Disable blur and shadow effects.
        shadow = { enabled = false },
        blur = { enabled = false },
    },

    animations = { enabled = true },
    dwindle = { preserve_split = true },
    cursor = { no_hardware_cursors = true },
    xwayland = { enabled = true },
    misc = { disable_hyprland_logo = true },
})

-- Curves used for animations. See https://www.cssportal.com/css-cubic-bezier-generator/.
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Hide selection GUI when making a screenshot.
hl.layer_rule({
    name = "hide-selection-animation",
    match = { namespace = "selection" },
    no_anim = true,
})

-- Ignore maximize requests.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Don't show a border if there is only one visible tiled window on the workspace.
-- Ignore transient floating windows such as tooltips and link previews.
hl.window_rule({
    name = "no-single-tiled-window-border",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
})

-- Move Spotify to workspace 1.
-- hl.window_rule({ name = "move-spotify", match = { class = "spotify" }, workspace = "1" })

-- Show different border color on floating windows.
hl.window_rule({
    name = "floating-window-border",
    match = { float = true },
    border_color = { colors = { "rgb(ff0000)", "rgb(ee00ff)" }, angle = 30 },
})

-- Hermes HUD overlay: transparent floating window, no border.
hl.window_rule({
    name = "hermes-hud-noborder",
    match = { class = "^(Hermes)$", title = "^(Hermes HUD)$" },
    border_size = 0,
})

-- Fix some dragging issues with XWayland.
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- hl.window_rule({
--     name = "anki-add-window",
--     match = { class = "^(anki)$", title = "^(Add)$" },
--     float = true,
--     size = "monitor_w/2-100 monitor_h-100",
--     move = "50 40",
-- })

-- }}}

-- INPUT {{{

hl.config({
    input = {
        -- By default, use DE keyboard layout, but allow switching to US layout with ALT+SPACE.
        kb_layout = "de,us",
        kb_options = "grp:alt_space_toggle",

        -- Mouse speed is default, without acceleration, and its position auto-focuses a window.
        sensitivity = 0,
        accel_profile = "flat",
        follow_mouse = 1,

        -- On touchpad, scroll in the expected direction and a bit slower.
        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.4,
            middle_button_emulation = true,
        },
    },
    gestures = { workspace_swipe_distance = 200 },
})

-- On laptop keyboard, use DE layout by default.
hl.device({ name = "at-translated-set-2-keyboard", kb_layout = "de,us" })

-- On HyperX keyboard, use DE layout by default.
hl.device({ name = "kingston-hyperx-alloy-fps-rgb", kb_layout = "de,us" })

-- On Glove80 keyboard, use US layout by default.
hl.device({ name = "glove80-keyboard", kb_layout = "us,de" })

-- Use three fingers on touchpad to switch between workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- }}}

-- KEYBINDINGS {{{

-- Keybinds with SUPER and A-Z, optionally with SHIFT.
hl.bind("SUPER + A", hl.dsp.exec_cmd("anki")) -- Open Anki
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("~/.config/hypr/record.sh")) -- Record rectangular video
hl.bind("SUPER + B", hl.dsp.exec_cmd(terminal .. " -e bluetui")) -- Manage bluetooth devices
hl.bind("SUPER + C", hl.dsp.window.close()) -- Close current window
hl.bind("SUPER + SHIFT + C", hl.dsp.window.kill()) -- Force close current window
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager)) -- Open file manager
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("rofi -modi emoji -show emoji")) -- Show emoji picker
hl.bind("SUPER + F", hl.dsp.exec_cmd(browser)) -- Open browser
hl.bind("SUPER + G", hl.dsp.exec_cmd("gimp")) -- Open GIMP
hl.bind("SUPER + H", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -i | cliphist decode | wl-copy")) -- Show clipboard history
hl.bind("SUPER + J", hl.dsp.layout("togglesplit")) -- Toggle vertical/horizontal split
hl.bind("SUPER + SHIFT + J", hl.dsp.window.swap({ next = true })) -- Swap windows
hl.bind("SUPER + K", hl.dsp.exec_cmd("rofi -show calc -modi calc -no-show-match -no-sort")) -- Show calculator
hl.bind("SUPER + L", hl.dsp.exec_cmd("rmpc pause && playerctl pause || true && hyprlock")) -- Lock and pause music
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("~/.config/hypr/lock-transparent.sh")) -- Lock with desktop still visible
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("~/.config/hypr/latex-ocr.sh")) -- Screenshot to LaTeX
hl.bind("SUPER + O", hl.dsp.exec_cmd("~/.config/hypr/open-obsidian-vault.sh")) -- Open Obsidian vault
hl.bind("SUPER + P", hl.dsp.window.pseudo()) -- Toggle pseudotiling
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pin()) -- Toggle window pinning
hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal .. " -e tmux")) -- Open terminal with tmux
hl.bind("SUPER + R", hl.dsp.exec_cmd(menu)) -- Show application launcher
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic")) -- Toggle special workspace
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy")) -- Take fullscreen screenshot
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd([[hyprctl eval 'hl.config({ animations = { enabled = false } })'; slurp | grim -g - - | wl-copy; hyprctl eval 'hl.config({ animations = { enabled = true } })']])) -- Take rectangular screenshot
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" })) -- Toggle floating/aligned window
hl.bind("SUPER + W", hl.dsp.exec_cmd("killall waybar 2>/dev/null || nohup waybar >/dev/null 2>&1 &")) -- Toggle waybar
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("chromium --app=https://waldo.moellh.com &>/dev/null"))
hl.bind("SUPER + CTRL + A", hl.dsp.exec_cmd("/home/henrikmoellmann/.local/bin/bridge-ctl toggle anki-connect; pkill -RTMIN+1 waybar"))
hl.bind("SUPER + CTRL + P", hl.dsp.exec_cmd("/home/henrikmoellmann/.local/bin/bridge-ctl toggle proxy; pkill -RTMIN+1 waybar"))

-- Cycle between windows in the current workspace.
hl.bind("SUPER + Tab", hl.dsp.window.cycle_next())

-- Select focused window with SUPER and arrow keys.
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with SUPER and a number; move the active window with SUPER+SHIFT and a number.
for workspace = 1, 10 do
    local key = workspace % 10 -- Workspace 10 maps to key 0.
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

-- Move and resize windows with ALT and the left mouse button.
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Audio multimedia keys. Legacy `bindel`: available while locked and repeating.
local lockedRepeating = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"), lockedRepeating)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), lockedRepeating)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), lockedRepeating)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), lockedRepeating)

-- Brightness control.
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), lockedRepeating)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), lockedRepeating)
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"))
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))

-- Player buttons. By default for playerctl, with SHIFT for rmpc. Legacy `bindl`: available while locked.
local locked = { locked = true }
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
hl.bind("SHIFT + XF86AudioNext", hl.dsp.exec_cmd("rmpc next"), locked)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("SHIFT + XF86AudioPause", hl.dsp.exec_cmd("rmpc toggle"), locked)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("SHIFT + XF86AudioPlay", hl.dsp.exec_cmd("rmpc togglepause"), locked)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)
hl.bind("SHIFT + XF86AudioPrev", hl.dsp.exec_cmd("rmpc prev"), locked)

-- Closing lid of laptop screen. TODO: Check if this actually works.
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("~/.config/hypr/lid.sh open"), locked)
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("~/.config/hypr/lid.sh close"), locked)

hl.bind("SUPER + CTRL + right", hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind("SUPER + CTRL + left", hl.dsp.workspace.move({ monitor = "-1" }))

-- }}}
