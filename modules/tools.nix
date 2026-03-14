{ pkgs, ... }: {
  home.packages = with pkgs; [
    wl-clipboard
    xclip

    cmatrix
    btop
  ];
}
