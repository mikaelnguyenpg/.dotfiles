# modules/desktop/hypr-daemons.nix
{ pkgs, ... }: {
  # Không có settings thì home-manager không ghi hypridle.conf -> hypridle
  # crash rồi restart mỗi 10s.
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
      };
      listener = [
        { timeout = 600; on-timeout = "loginctl lock-session"; } # 10 phút -> khoá
      ];
    };
  };
  programs.hyprlock.enable = true;

  # Hyprland không tự báo pin yếu (GNOME/KDE mới có) -> batsignal gửi thông
  # báo qua mako. Ngưỡng khớp với services.upower ở hosts/nixos/power.nix
  # (25/15/8%; tới 8% upower tự suspend).
  services.batsignal = {
    enable = true;
    extraArgs = [
      "-w" "25" "-c" "15" "-d" "8"
      "-W" "Pin còn dưới 25% — nên cắm sạc"
      "-C" "Pin còn dưới 15% — lưu công việc và cắm sạc ngay!"
      "-p" # báo khi cắm/rút sạc
    ];
  };
  # Wallpaper giờ do wayle quản lý (backend swww) để có auto-retheme theo
  # matugen — xem modules/wayle.nix. hyprpaper tắt để khỏi có 2 daemon tranh nhau.

  home.packages = with pkgs; [
    grim
    slurp
    wf-recorder
    cliphist
    wl-clipboard
    brightnessctl
    hyprpolkitagent
    pavucontrol
    networkmanagerapplet
    blueman
    gnome-control-center
    matugen
    awww
  ];
}
