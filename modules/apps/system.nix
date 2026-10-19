# modules/apps/system.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ─── VM ───────────────────────────────────────────────────────────────────────
    gnome-boxes

    # ─── VPN ──────────────────────────────────────────────────────────────────────
    proton-vpn

    wireguard-tools
  ];
}
