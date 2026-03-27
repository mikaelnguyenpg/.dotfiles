# =============================================================================
# hosts/nixos/mount.nix — NixOS system configuration
# =============================================================================
{ ... }: {

  # ─── Mount points ───────────────────────────────────────────────────────────

  fileSystems."/data" = {
    device  = "/dev/disk/by-uuid/b9ef6f32-d3c1-4356-8c0d-8e6ef137a830";
    fsType  = "ext4";
    options = [ "defaults" ];
  };

  fileSystems."/mnt/build_cache" = {
    device  = "/dev/disk/by-uuid/0097bbe4-2b94-411c-8286-f7e29cc833a0";
    fsType  = "ext4";
    options = [ "defaults" ];
  };

  # ─── Swap ───────────────────────────────────────────────────────────────────

  # swapDevices = [{
  #   device = "/mnt/build_cache/swapfile";
  # }];

  # ─── Ownership ──────────────────────────────────────────────────────────────
  # NixOS không có chown trực tiếp, dùng systemd tmpfiles thay thế

  # systemd.tmpfiles.rules = [
  #   "d /data              0755 codevibe users -"
  #   "d /mnt/build_cache   0755 codevibe users -"
  # ];
}
