# modules/hypr-daemons.nix
{ pkgs, ... }: {
  services.hypridle.enable = true;
  programs.hyprlock.enable = true;
  # Wallpaper giờ do wayle quản lý (backend swww) để có auto-retheme theo
  # matugen — xem modules/wayle.nix. hyprpaper tắt để khỏi có 2 daemon tranh nhau.

  home.packages = with pkgs; [
    grim
    slurp
    wf-recorder
    cliphist
    wl-clipboard
    brightnessctl
    hyprpolkitagent
    pavucontrol
    networkmanagerapplet
    blueman
    gnome-control-center
    matugen
    awww
  ];
}
