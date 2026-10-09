# modules/apps/communication.nix
{ pkgs, ... }:

let
  # Ép dùng backend gnome-libsecret: Electron tự chọn password-store theo
  # XDG_CURRENT_DESKTOP, và "Hyprland" không nằm trong danh sách nó nhận diện
  # nên fallback về basic_text (plaintext) dù gnome-keyring vẫn unlock sẵn qua
  # GDM/PAM. Ép cứng để DB local dùng chung 1 backend trên cả GNOME lẫn Hyprland.
  #
  # Dùng wrapper thay cho `override { commandLineArgs }` (đã deprecated). File
  # .desktop gọi `signal-desktop` qua PATH nên mở từ menu/rofi cũng nhận flag.
  signal-desktop = pkgs.symlinkJoin {
    name = "signal-desktop-${pkgs.signal-desktop.version}";
    paths = [ pkgs.signal-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/signal-desktop \
        --add-flags "--password-store=gnome-libsecret"
    '';
    inherit (pkgs.signal-desktop) meta;
  };
in {
  home.packages = [
    signal-desktop
    pkgs.zoom-us
  ];
}
