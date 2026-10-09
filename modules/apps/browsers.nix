# modules/apps/browsers.nix
{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
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
    # tor-browser
  ];
}
