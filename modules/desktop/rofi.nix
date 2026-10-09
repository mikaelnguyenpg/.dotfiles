{ pkgs, ... }: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "${pkgs.ghostty}/bin/ghostty";
    font = "JetBrainsMono Nerd Font 12";
  };
}
