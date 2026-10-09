# modules/dev/ide.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # vimPlugins.LazyVim
    antigravity-ide
    android-studio
    devin-desktop
    geany

    # (Optional)
    # code-cursor
    # zed-editor
    # jetbrains.webstorm
    # kdePackages.kate
    # lite-xl
    # lapce
  ];
}
