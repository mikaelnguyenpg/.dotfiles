{ pkgs, ... }: {
  # ─── Input Method ───────────────────────────────────────────────────────────
  i18n.inputMethod = {
    enabled = "fcitx5";
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
}
