{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # ─── VM & System Tools ────────────────────────────────────────────────────────

    gnome-boxes

    # ─── Browser ──────────────────────────────────────────────────────────────────

    (google-chrome.override {
      commandLineArgs = lib.concatStringsSep " " [
        # Cùng lý do với signal-desktop: XDG_CURRENT_DESKTOP=Hyprland không được
        # Chromium nhận diện nên tự fallback password-store, làm mất/không đọc
        # được passwords & cookie đã lưu (Zalo/Facebook... tự logout). Ép cứng
        # backend để dùng chung keyring với bên GNOME.
        "--password-store=gnome-libsecret"
        # Video YouTube bị vỡ hình (còn tiếng) do nvidia-vaapi-driver export
        # surface lỗi ("vaExportSurfaceHandle failed, VA error: resource
        # allocation failed" — xác nhận trực tiếp từ log Chrome trên máy này).
        # Tắt hardware video decode, dùng software decode cho ổn định.
        "--disable-accelerated-video-decode"
      ];
    })
    # chromium
    tor-browser

    # ─── Communication ────────────────────────────────────────────────────────────

    # Ép dùng backend gnome-libsecret: Electron tự chọn password-store theo
    # XDG_CURRENT_DESKTOP, và "Hyprland" không nằm trong danh sách nó nhận diện
    # nên fallback về basic_text (plaintext) dù gnome-keyring vẫn unlock sẵn qua
    # GDM/PAM. Ép cứng để DB local dùng chung 1 backend trên cả GNOME lẫn Hyprland.
    (signal-desktop.override {
      commandLineArgs = "--password-store=gnome-libsecret";
    })
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

    fastfetch

    tuios
    herdr
  ];
}
