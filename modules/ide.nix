{ pkgs, ... }: {
  home.packages = with pkgs; [
    # vimPlugins.LazyVim
    antigravity-ide
    android-studio

    # (Optional)
    # code-cursor
    # claude-code
    # zed-editor
    # jetbrains.webstorm
    devin-desktop
    geany
    # kdePackages.kate
    # lite-xl
    # lapce
  ];
}
