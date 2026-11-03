# modules/dev/packagemanager.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    uv
  ];
}
