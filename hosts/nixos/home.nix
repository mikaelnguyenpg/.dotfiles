# =============================================================================
# home.nix — Home-manager config cho máy NixOS
# =============================================================================
{ lib, ... }:
let
  # --- CẤU HÌNH TIER Ở ĐÂY ---
  # Chọn: "minimal", "standard", hoặc "full"  (xem modules/home/tiers.nix)
  tier = "full";

  # Module tier full chỉ dành cho máy này (phần dùng chung nằm ở modules/home/full.nix)
  hostFullModules = [
    ../../modules/cli/extras.nix
    # ../../modules/cli/ytdlp.nix
    ../../modules/dev/api-tools.nix
    ../../modules/apps/browsers.nix
    ../../modules/apps/communication.nix
    ../../modules/apps/media.nix
    ../../modules/apps/productivity.nix
    ../../modules/apps/system.nix
  ];
in {
  imports = import ../../modules/home/tiers.nix { inherit lib tier; }
    ++ lib.optionals (tier == "full") hostFullModules
    # Desktop độc lập với tier CLI
    ++ [ ../../modules/home/desktop.nix ];

  # Tự restart các systemd --user service bị đổi sau khi switch, khỏi cần
  # logout/login lại (áp dụng cho wayle, hypridle, hyprpaper, ...)
  systemd.user.startServices = "sd-switch";
}
