# hosts/nixos/fonts.nix
{ pkgs, ... }: {
  fonts.fontDir.enable = true;
  
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts
    noto-fonts-color-emoji
  ];
}
