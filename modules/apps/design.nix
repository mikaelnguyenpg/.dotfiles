# modules/apps/design.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    figma-linux
    kdePackages.kolourpaint
  ];
}
