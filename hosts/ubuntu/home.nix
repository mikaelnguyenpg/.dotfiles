# =============================================================================
# home.nix — Home-manager (standalone) cho máy Ubuntu
# =============================================================================
{ lib, ... }:
let
  # --- CẤU HÌNH TIER Ở ĐÂY ---
  # Chọn: "minimal", "standard", hoặc "full"  (xem modules/home/tiers.nix)
  tier = "full";
in {
  imports = import ../../modules/home/tiers.nix { inherit lib tier; }
    ++ [
      # Standalone home-manager tự quản lý nixpkgs.config (allowUnfree, ...)
      ../../modules/core/nixpkgs.nix
    ]
    ++ lib.optionals (tier == "full") [
      # App GUI trên distro không phải NixOS cần nixGL để chạy OpenGL
      ../../modules/core/nixGL.nix
      # ../../modules/cli/ytdlp.nix
    ];
}
