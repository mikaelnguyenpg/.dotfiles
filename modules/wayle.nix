# modules/wayle.nix
# HyprPanel is archived (2026-04-27); upstream migrated to Wayle
# (https://wayle.app). Wayle's `services.wayle` home-manager module manages
# its own systemd user service, so no exec-once needed in hyprland.conf.
{ pkgs, config, ... }:
let
  wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
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

  services.wayle = {
    enable = true;
    autoInstallDependencies = true;
    settings = {
      # bar.layout phải là MẢNG các layout theo từng monitor (schema: BarLayout[]),
      # và tên module đúng theo BarModule enum (vd: "hyprland-workspaces", không phải "workspaces").
      bar.layout = [
        {
          left = [ "hyprland-workspaces" ];
          center = [ "clock" ];
          right = [ "media" "microphone" "volume" "network" "bluetooth" "battery" "dashboard" ];
        }
      ];
      # Auto-retheme: đổi wallpaper (qua `wayle wallpaper set ...`) là màu bar/
      # dropdown tự đổi theo (Material You), nhờ matugen trích màu từ ảnh.
      # Cần package matugen + swww (xem hypr-daemons.nix).
      styling.theme-provider = "matugen";
      wallpaper = {
        cycling-enabled = true;
        cycling-mode = "shuffle";
        # Bộ ảnh riêng của bạn, không phải thư mục curated ở trên.
        cycling-directory = "${config.home.homeDirectory}/Pictures/Wallpaper-Bank/wallpapers/Dynamic-Wallpapers/Dark";
        monitors = [
          {
            name = "eDP-1";
            wallpaper = "${config.home.homeDirectory}/Pictures/Wallpaper-Bank/wallpapers/Dynamic-Wallpapers/Dark/Fuji-Dark.png";
          }
        ];
      };
      modules = {
        clock.format = "%H:%M";
        # Default (loginctl lock-session / terminate-session) cần 1 trình lắng
        # nghe D-Bus signal từ logind mà Hyprland không có sẵn (GNOME thì có
        # gnome-shell làm việc này) nên bấm không có tác dụng. Đổi sang đúng
        # lệnh mà keybind $mod+SHIFT+L / $mod+SHIFT+E trong hyprland.conf đang
        # dùng và đã biết chắc hoạt động.
        dashboard = {
          dropdown-lock-command = "hyprlock";
          dropdown-logout-command = "hyprctl dispatch exit";
        };
      };
    };
  };
}
