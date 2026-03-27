{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # ─── VM & System Tools ────────────────────────────────────────────────────────

    gnome-boxes

    # ─── Browser ──────────────────────────────────────────────────────────────────

    google-chrome
    # chromium

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

    drawing

    # ─── Development ──────────────────────────────────────────────────────────────

    jetbrains.webstorm
    httpie-desktop
  ];
}
