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
    bruno
    apidog

    # ─── VPN ──────────────────────────────────────────────────────────────────────
    # pritunl-client
    # protonvpn-gui
    proton-vpn

    # Tmp
    super-productivity

    superfile

    # # GPT tools
    aichat
    # mods
    # tgpt

    # # Browser tools
    ddgr
    w3m
    # browsh
  ];
}
