{ pkgs, ... }: {
  home.packages = with pkgs; [
    vimPlugins.LazyVim

    # (Optional)
    code-cursor
    claude-code
  ];
}
