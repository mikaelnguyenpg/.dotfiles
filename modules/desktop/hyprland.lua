-- modules/desktop/hyprland.lua -> ~/.config/hypr/hyprland.lua
-- Hyprland >= 0.57 bỏ hẳn hyprlang (hyprland.conf), chỉ đọc Lua.
-- Bản hyprlang cũ: archive/hyprland-hyprlang.conf
-- Kiểm tra cú pháp: Hyprland --verify-config -c modules/desktop/hyprland.lua
-- API: https://wiki.hypr.land/configuring/

local mod  = "SUPER"
local term = "ghostty"

------------------------------
---- ENV / MONITOR / LOOK ----
------------------------------

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
    decoration = {
        rounding = 10,
        blur = { enabled = true, size = 6, passes = 3 },
    },
})

hl.layer_rule({
    name  = "bar_blur",
    match = { namespace = "^(wayle-bar-.*)$" },
    blur  = true,
})

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    -- Safety net: wayle/hypridle (home-manager services) chỉ tự start khi
    -- Hyprland được launch qua UWSM (activate graphical-session.target). Nếu
    -- GDM lỡ chọn nhầm entry "Hyprland" thường, start thẳng từng service.
    hl.exec_cmd("systemctl --user start wayle.service hypridle.service")
    hl.exec_cmd("mako")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("hyprpolkitagent")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("fcitx5 -d")
end)

---------------------
---- KEYBINDINGS ----
---------------------

local function bind(keys, cmd, flags)
    hl.bind(keys, hl.dsp.exec_cmd(cmd), flags)
end

bind(mod .. " + Return", term)
hl.bind(mod .. " + Q", hl.dsp.window.close())
bind(mod .. " + R", "rofi -show drun")
bind(mod .. " + V", "cliphist list | rofi -dmenu | cliphist decode | wl-copy")
bind(mod .. " + SHIFT + T", "wayle panel settings")
bind(mod .. " + SHIFT + N", "wayle wallpaper next")
bind(mod .. " + SHIFT + P", "wayle wallpaper previous")
bind(mod .. " + SHIFT + L", "hyprlock")
-- Lock màn hình trước rồi mới suspend, tránh lộ màn hình vài giây lúc chờ ngủ
bind(mod .. " + SHIFT + S", "hyprlock & sleep 1 && systemctl suspend")
-- Tắt/bật thông báo (xem modules/desktop/mako.nix)
bind(mod .. " + N", "notif-mode do-not-disturb")
bind(mod .. " + ALT + N", "notif-mode mute-signal")

hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())

hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 9 do
    hl.bind(mod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad (special workspace)
hl.bind(mod .. " + Space",         hl.dsp.workspace.toggle_special("special"))
hl.bind(mod .. " + SHIFT + Space", hl.dsp.window.move({ workspace = "special:special" }))

hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- Screenshot
bind("Print", [[grim -g "$(slurp)" - | wl-copy]])
bind("SHIFT + Print", "grim - | wl-copy")
bind(mod .. " + S", [[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy]])

-- Volume / brightness (phím media vật lý)
local media = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume",  "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+", media)
bind("XF86AudioLowerVolume",  "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", media)
bind("XF86AudioMute",         "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true })
bind("XF86MonBrightnessUp",   "brightnessctl set 5%+", media)
bind("XF86MonBrightnessDown", "brightnessctl set 5%-", media)

-- Kéo / resize cửa sổ floating bằng chuột
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Thoát Hyprland / reload config
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
bind(mod .. " + SHIFT + R", "hyprctl reload")
