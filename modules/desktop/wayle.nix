# modules/desktop/wayle.nix
# HyprPanel is archived (2026-04-27); upstream migrated to Wayle
# (https://wayle.app). Wayle's `services.wayle` home-manager module manages
# its own systemd user service, so no autostart needed in hyprland.lua.
{ pkgs, config, lib, ... }:
let
  wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
  wallpaperBank = "${config.home.homeDirectory}/Pictures/Wallpaper-Bank/wallpapers";

  # TẠM THỜI (2026-11): nixpkgs @ f4a03c0 link wayle với sqlite của hệ thống
  # nhưng package quên khai báo sqlite -> "ld: cannot find -lsqlite3".
  # Chỉ thêm khi còn thiếu, nixpkgs sửa rồi thì tự thành no-op -> xoá được.
  wayle =
    if lib.elem pkgs.sqlite (pkgs.wayle.buildInputs or [ ]) then pkgs.wayle
    else pkgs.wayle.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.sqlite ];
    });
in {
  # Gom vài wallpaper vào 1 thư mục để wayle list/cycle được (giữ luôn 3 hình
  # mặc định của Hyprland — wall0/1/2.png, trong đó có hình "cô gái ngồi" —
  # phòng khi muốn quay lại).
  home.file = {
    "Pictures/Wallpapers/hyprland-wall0.png".source = "${pkgs.hyprland}/share/hypr/wall0.png";
    "Pictures/Wallpapers/hyprland-wall1.png".source = "${pkgs.hyprland}/share/hypr/wall1.png";
    "Pictures/Wallpapers/hyprland-wall2.png".source = "${pkgs.hyprland}/share/hypr/wall2.png";
    "Pictures/Wallpapers/nixos-simple-blue.png".source =
      "${pkgs.nixos-artwork.wallpapers.simple-blue}/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
    "Pictures/Wallpapers/nixos-catppuccin-mocha.png".source =
      "${pkgs.nixos-artwork.wallpapers.catppuccin-mocha}/share/backgrounds/nixos/nixos-wallpaper-catppuccin-mocha.png";
    "Pictures/Wallpapers/nixos-dracula.png".source =
      "${pkgs.nixos-artwork.wallpapers.dracula}/share/backgrounds/nixos/nix-wallpaper-dracula.png";
  };

  # waypaper: cửa sổ xem trước & chọn wallpaper bằng chuột. backend "none" +
  # post_command -> waypaper chỉ chọn hình, còn việc đặt hình vẫn do wayle làm
  # (giữ auto-retheme matugen, không 2 tool tranh nhau vẽ nền).
  # use_xdg_state: waypaper ghi trạng thái vào ~/.local/state thay vì ghi đè
  # config.ini (file này do Nix quản lý, chỉ đọc).
  home.packages = [ pkgs.waypaper ];
  xdg.configFile."waypaper/config.ini".text = ''
    [Settings]
    folder = ${wallpaperBank}
    all_subfolders = True
    backend = none
    fill = fill
    post_command = wayle wallpaper set $wallpaper
    use_xdg_state = True
  '';

  services.wayle = {
    enable = true;
    package = wayle;
    autoInstallDependencies = true;
    settings = {
      # bar.layout phải là MẢNG các layout theo từng monitor (schema: BarLayout[]),
      # và tên module đúng theo BarModule enum (vd: "hyprland-workspaces", không phải "workspaces").
      bar.layout = [
        {
          left = [ "hyprland-workspaces" ];
          center = [ "clock" ];
          # systray: hiện icon của app chạy nền (nm-applet -> menu VPN/WireGuard,
          # fcitx, blueman, signal, pritunl, ...)
          right = [ "media" "microphone" "volume" "network" "bluetooth" "battery" "systray" "dashboard" ];
        }
      ];
      # Auto-retheme: đổi wallpaper (qua `wayle wallpaper set ...`) là màu bar/
      # dropdown tự đổi theo (Material You), nhờ matugen trích màu từ ảnh.
      # Cần package matugen + swww (xem hypr-daemons.nix).
      styling.theme-provider = "matugen";
      wallpaper = {
        cycling-enabled = true;
        cycling-mode = "shuffle";
        cycling-interval-mins = 5;
        # Bộ ảnh riêng của bạn (~160 hình), không phải thư mục curated ở trên.
        # Lưu ý: chỉnh wallpaper trong Settings của wayle sẽ ghi vào
        # ~/.config/wayle/runtime.toml và ĐÈ lên các giá trị ở đây
        # -> `wayle config reset wallpaper.<field>` để quay về config Nix.
        cycling-directory = wallpaperBank;
        monitors = [ { name = "eDP-1"; fit-mode = "fill"; } ];
      };
      modules = {
        clock.format = "%H:%M";
        # Default (loginctl lock-session / terminate-session) cần 1 trình lắng
        # nghe D-Bus signal từ logind mà Hyprland không có sẵn (GNOME thì có
        # gnome-shell làm việc này) nên bấm không có tác dụng. Đổi sang đúng
        # lệnh mà keybind $mod+SHIFT+L / $mod+SHIFT+E trong hyprland.lua đang
        # dùng và đã biết chắc hoạt động.
        dashboard = {
          dropdown-lock-command = "hyprlock";
          # Hyprland >= 0.57: dispatcher là biểu thức Lua
          dropdown-logout-command = "hyprctl dispatch 'hl.dsp.exit()'";
        };
      };
    };
  };
}
