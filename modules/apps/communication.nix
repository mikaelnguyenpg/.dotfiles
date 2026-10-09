# modules/apps/communication.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Ép dùng backend gnome-libsecret: Electron tự chọn password-store theo
    # XDG_CURRENT_DESKTOP, và "Hyprland" không nằm trong danh sách nó nhận diện
    # nên fallback về basic_text (plaintext) dù gnome-keyring vẫn unlock sẵn qua
    # GDM/PAM. Ép cứng để DB local dùng chung 1 backend trên cả GNOME lẫn Hyprland.
    (signal-desktop.override {
      commandLineArgs = "--password-store=gnome-libsecret";
    })
    zoom-us
  ];
}
