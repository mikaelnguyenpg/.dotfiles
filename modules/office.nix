{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # ─── VM & System Tools ────────────────────────────────────────────────────────

    gnome-boxes

    # ─── Browser ──────────────────────────────────────────────────────────────────

    google-chrome
    # chromium
    tor-browser

    # ─── Communication ────────────────────────────────────────────────────────────

    signal-desktop
    zoom-us

    # ─── Productivity & Notes ─────────────────────────────────────────────────────

    obsidian
    notepad-next

    # ─── Office ───────────────────────────────────────────────────────────────────

    libreoffice

    # ─── Media ────────────────────────────────────────────────────────────────────

    vlc
    obs-studio

    # ─── Graphics & Drawing ───────────────────────────────────────────────────────

    kdePackages.kolourpaint

    # ─── Development ──────────────────────────────────────────────────────────────

    httpie-desktop

    # ─── VPN ──────────────────────────────────────────────────────────────────────
    protonvpn-gui

    # Tmp
    super-productivity
  ];
}
