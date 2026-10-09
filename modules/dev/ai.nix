# modules/dev/ai.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    claude-code
    aichat
    # mods
    # tgpt
  ];
}
