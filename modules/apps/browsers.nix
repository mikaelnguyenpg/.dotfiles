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
        # Giới hạn cache trang web 512MB (để mặc định Chrome từng phình lên 7GB+).
        # Giới hạn tính RIÊNG cho mỗi profile (máy có 4 profile) và không gồm
        # "Code Cache" → tổng thực tế ~2-3GB.
        # Chỉ ảnh hưởng ~/.cache/google-chrome; mật khẩu/bookmark/lịch sử nằm
        # ở ~/.config/google-chrome, không bị đụng tới.
        "--disk-cache-size=536870912"
      ];
    })
    # chromium
    # tor-browser
  ];
}
