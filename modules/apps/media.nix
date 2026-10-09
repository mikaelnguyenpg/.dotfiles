# modules/apps/media.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    vlc
    obs-studio
  ];
}
