# modules/hyprland.nix
{ pkgs, ... }: {
  dconf.settings = {
   "org/gnome/desktop/interface" = {
     cursor-theme = "Adwaita";
     cursor-size = 24;
   };
  };

  home.file.".config/hypr/hyprland.conf".text = ''
    $mod = SUPER
    $term = ghostty

    env = XCURSOR_THEME,Adwaita
    env = XCURSOR_SIZE,24
    env = HYPRCURSOR_THEME,Adwaita
    env = HYPRCURSOR_SIZE,24
    env = WLR_NO_HARDWARE_CURSORS,1
    env = LIBVA_DRIVER_NAME,nvidia
    env = GBM_BACKEND,nvidia-drm
    env = __GLX_VENDOR_LIBRARY_NAME,nvidia
    env = GTK_IM_MODULE,fcitx
    env = QT_IM_MODULE,fcitx
    env = XMODIFIERS,@im=fcitx

    monitor = , preferred, auto, 1

    decoration {
      rounding = 10
      blur {
        enabled = true
        size = 6
        passes = 3
      }
    }

    layerrule {
      name = bar_blur
      match:namespace = ^(wayle-bar-.*)$
      blur = true
    }

    # Safety net: wayle/hypridle/hyprpaper (home-manager services) chỉ tự start
    # khi Hyprland được launch qua UWSM (activate graphical-session.target).
    # Nếu GDM lỡ chọn nhầm entry "Hyprland" thường (không phải "Hyprland
    # (uwsm-managed)"), target đó không active và 3 service này sẽ không chạy.
    # Start thẳng từng service (không đụng target, vì graphical-session.target
    # tự chặn start thủ công) để luôn hoạt động bất kể chọn session nào.
    exec-once = systemctl --user start wayle.service hypridle.service hyprpaper.service
    exec-once = mako
    exec-once = wl-paste --watch cliphist store
    exec-once = hyprpolkitagent
    exec-once = nm-applet --indicator
    exec-once = blueman-applet
    exec-once = fcitx5 -d

    bind = $mod, Return, exec, $term
    bind = $mod, Q, killactive
    bind = $mod, R, exec, rofi -show drun
    bind = $mod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy
    bind = $mod SHIFT, L, exec, hyprlock
    # Lock màn hình trước rồi mới suspend, tránh lộ màn hình vài giây lúc chờ ngủ
    bind = $mod SHIFT, S, exec, hyprlock & sleep 1 && systemctl suspend
    bind = $mod, F, fullscreen
    bind = $mod, left, movefocus, l
    bind = $mod, right, movefocus, r
    bind = $mod, up, movefocus, u
    bind = $mod, down, movefocus, d
    bind = $mod, 1, workspace, 1
    bind = $mod SHIFT, 1, movetoworkspace, 1
    bind = $mod, 2, workspace, 2
    bind = $mod SHIFT, 2, movetoworkspace, 2
    bind = $mod, 3, workspace, 3
    bind = $mod SHIFT, 3, movetoworkspace, 3
    bind = $mod, 4, workspace, 4
    bind = $mod SHIFT, 4, movetoworkspace, 4
    bind = $mod, 5, workspace, 5
    bind = $mod SHIFT, 5, movetoworkspace, 5
    bind = $mod, 6, workspace, 6
    bind = $mod SHIFT, 6, movetoworkspace, 6
    bind = $mod, 7, workspace, 7
    bind = $mod SHIFT, 7, movetoworkspace, 7
    bind = $mod, 8, workspace, 8
    bind = $mod SHIFT, 8, movetoworkspace, 8
    bind = $mod, 9, workspace, 9
    bind = $mod SHIFT, 9, movetoworkspace, 9

    # Screenshot
    bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
    bind = SHIFT, Print, exec, grim - | wl-copy
    bind = $mod, S, exec, mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy

    # Volume / brightness (phim media vat ly)
    binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
    binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bind  = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    binde = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
    binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

    # Keo / resize cua so floating bang chuot
    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow

    # Thoat Hyprland / reload config
    bind = $mod SHIFT, E, exit
    bind = $mod SHIFT, R, exec, hyprctl reload

    bind = $mod SHIFT, F, togglefloating
    bind = $mod, P, pseudo
    bind = $mod, Space, togglespecialworkspace
    bind = $mod SHIFT, Space, movetoworkspace, special
    bind = ALT, Tab, cyclenext
    bind = ALT, Tab, bringactivetotop
  '';
}
