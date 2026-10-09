# modules/input-method.nix
{ pkgs, ... }: {

  # Wayland environment variables — bắt buộc cho fcitx5 + Wayland
  home.sessionVariables = {
    XMODIFIERS            = "@im=fcitx";
    GTK_IM_MODULE         = "fcitx";
    QT_IM_MODULE          = "fcitx";
    QT_IM_MODULES         = "fcitx";
    INPUT_METHOD          = "fcitx";
    IMSETTINGS_MODULE     = "fcitx";
    # Wayland-specific
    SDL_IM_MODULE         = "fcitx";
    GLFW_IM_MODULE        = "ibus";  # một số app dùng GLFW cần cái này
  };

  # Autostart fcitx5 khi login (Wayland session)
  xdg.configFile."autostart/fcitx5.desktop".text = ''
    [Desktop Entry]
    Name=Fcitx5
    Exec=fcitx5 --replace -d
    Type=Application
    X-GNOME-Autostart-enabled=true
  '';
}
