# modules/hypr-daemons.nix
{ pkgs, ... }: {
  services.hypridle.enable = true;
  programs.hyprlock.enable = true;
  services.hyprpaper.enable = true;

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
  ];
}
