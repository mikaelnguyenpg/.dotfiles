{ pkgs, ... }: {
  home.packages = with pkgs; [
    helix

    # (Optional)
    code-cursor
    claude-code
  ];
}
