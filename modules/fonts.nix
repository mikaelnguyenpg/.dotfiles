# modules/fonts.nix
{ pkgs, ... }: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.comic-shanns-mono
    nerd-fonts.symbols-only
  ];
}
