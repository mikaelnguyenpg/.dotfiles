{ pkgs, ... }: {
  # ─── Input Method ───────────────────────────────────────────────────────────
  i18n.inputMethod = {
    enable = true;
    type    = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-bamboo                     # bamboo
        fcitx5-chewing                    # chewing
        qt6Packages.fcitx5-chinese-addons # pinyin
        fcitx5-gtk
        qt6Packages.fcitx5-qt
        qt6Packages.fcitx5-configtool
      ];
    };
  };

  # BỔ SUNG ĐOẠN NÀY: Ép hệ thống nhận diện bộ gõ toàn cục
  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    # Sửa lỗi riêng cho các app Electron / Chromium chạy dưới Wayland
    NIXOS_OZONE_WL = "1"; 
  };
}
