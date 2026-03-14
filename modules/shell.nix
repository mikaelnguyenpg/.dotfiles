{ pkgs, ... }: {
  home.packages = with pkgs; [
    xclip # Copy to clipboard for X11
    wl-clipboard # Copy to clipboard for Wayland
  ];
}
