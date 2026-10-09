# modules/dev/api-tools.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    httpie-desktop
    bruno
    apidog
  ];
}
