{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;   # cần cho app X11 legacy (1 số Electron/Java app cũ)
  };
}
