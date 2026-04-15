{ pkgs, ... }: {
  home.packages = with pkgs; [
    # vimPlugins.LazyVim

    # (Optional)
    # code-cursor
    # claude-code
    # zed-editor
    # jetbrains.webstorm
    windsurf
    geany
    # kdePackages.kate
    # lite-xl
    # lapce
  ];
}
