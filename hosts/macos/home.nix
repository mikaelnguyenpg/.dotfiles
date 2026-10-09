# =============================================================================
# home.nix — Home-manager cho macOS (qua nix-darwin)
# =============================================================================
{ lib, ... }:
let
  # --- CẤU HÌNH TIER Ở ĐÂY ---
  # Chọn: "minimal", "standard", hoặc "full"  (xem modules/home/tiers.nix)
  # Lưu ý: tier full gồm nhiều app chỉ có trên Linux
  tier = "minimal";
in {
  imports = import ../../modules/home/tiers.nix { inherit lib tier; }
    ++ [
      ../../modules/dev/containers.nix
    ];

  nixpkgs.config.allowUnfree = true;
}
