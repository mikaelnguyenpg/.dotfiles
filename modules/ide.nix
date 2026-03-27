{ pkgs, ... }: {
  home.packages = with pkgs; [
    # (Optional)
    code-cursor
    claude-code
  ];
}
